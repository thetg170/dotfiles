local M = {}

local last_run = nil
local output_terminal = nil

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Python Run" })
end

local function project_root(file)
  local start = (file and file ~= "") and file or vim.uv.cwd()
  return vim.fs.root(start, { "pyproject.toml", ".venv", ".git" }) or vim.uv.cwd()
end

local function exercise_root(file)
  if file ~= "" and vim.fn.fnamemodify(file, ":e") == "py" then
    return vim.fs.root(file, function(name, path)
      return name == ".exercism" and vim.fn.filereadable(vim.fs.joinpath(path, name, "config.json")) == 1
    end)
  end
end

local function find_python(root)
  if type(root) == "string" then
    local venv_python = vim.fs.joinpath(root, ".venv", "bin", "python")
    if vim.fn.executable(venv_python) == 1 then
      return { venv_python }, venv_python
    end
  end

  local active_venv = vim.env.VIRTUAL_ENV
  if active_venv and active_venv ~= "" then
    local active_python = vim.fs.joinpath(active_venv, "bin", "python")
    if vim.fn.executable(active_python) == 1 then
      return { active_python }, active_python
    end
  end

  if type(root) == "string" and vim.fn.filereadable(vim.fs.joinpath(root, "pyproject.toml")) == 1 then
    if vim.fn.executable("uv") == 1 then
      return { "uv", "run", "python" }, "uv run python"
    end
  end

  if vim.fn.executable("python3") == 1 then
    return { "python3" }, "python3"
  end

  return { "python" }, "python"
end

local function display_path(root, file)
  if type(root) == "string" and vim.startswith(file, root .. "/") then
    return file:sub(#root + 2)
  end
  return file
end

local function run_in_terminal(cmd_list, opts)
  opts = opts or {}
  local cwd = opts.cwd or vim.uv.cwd()
  local label = opts.label or table.concat(cmd_list, " ")

  if opts.remember ~= false then
    last_run = {
      cmd_list = vim.deepcopy(cmd_list),
      cwd = cwd,
      label = label,
    }
  end

  local wrapper = [[
label="$1"
shift
printf '\033[1;36m▶ %s\033[0m\n\n' "$label"
start_ns=$(python3 -c 'import time; print(time.monotonic())' 2>/dev/null || date +%s)
"$@"
status=$?
end_ns=$(python3 -c 'import time; print(time.monotonic())' 2>/dev/null || date +%s)
elapsed=$(python3 -c "print(f'{float('$end_ns') - float('$start_ns'):.2f}s')" 2>/dev/null || echo "")
printf '\n'
if [ "$status" -eq 0 ]; then
  printf '\033[1;32m✓ PASS (exit 0%s)\033[0m\n' "${elapsed:+ · $elapsed}"
else
  printf '\033[1;31m✗ FAIL (exit %d%s)\033[0m\n' "$status" "${elapsed:+ · $elapsed}"
fi
exit "$status"
]]

  local wrapped_cmd = { "/bin/sh", "-c", wrapper, "python-run", label }
  vim.list_extend(wrapped_cmd, cmd_list)

  -- The terminal toggle can reopen a finished job when its command is repeated.
  if output_terminal then
    output_terminal:close()
  end
  output_terminal = Snacks.terminal.open(wrapped_cmd, {
    cwd = cwd,
    env = {
      PYTHONUNBUFFERED = "1",
      FORCE_COLOR = "1",
    },
    interactive = false,
    auto_close = false,
    win = {
      position = "bottom",
      height = 0.35,
      wo = {
        wrap = true,
      },
    },
  })
end

local function current_python_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    notify("Save the buffer before running Python", vim.log.levels.WARN)
    return nil
  end
  if vim.bo.filetype ~= "python" then
    notify("Current buffer is not a Python file", vim.log.levels.WARN)
    return nil
  end
  vim.cmd("silent update")
  return file
end

function M.run_file(extra_args)
  local file = current_python_file()
  if not file then
    return
  end
  if extra_args == nil and exercise_root(file) then
    return M.run_pytest()
  end

  local root = project_root(file)
  local cmd, py_label = find_python(root)
  table.insert(cmd, "-u")
  table.insert(cmd, file)

  local label_parts = { py_label, "-u", display_path(root, file) }
  if extra_args and #extra_args > 0 then
    vim.list_extend(cmd, extra_args)
    vim.list_extend(label_parts, extra_args)
  end

  run_in_terminal(cmd, {
    cwd = root,
    label = table.concat(label_parts, " "),
  })
end

function M.run_file_with_args()
  local file = current_python_file()
  if not file then
    return
  end

  vim.ui.input({ prompt = "Python args: " }, function(input)
    if input == nil then
      return
    end
    local args = {}
    for arg in input:gmatch("%S+") do
      table.insert(args, arg)
    end
    M.run_file(args)
  end)
end

function M.run_pytest()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" and vim.bo.modified then
    vim.cmd("silent update")
  end

  local root = project_root(file)
  local exercise = exercise_root(file)
  local cmd, py_label = find_python(root)
  vim.list_extend(cmd, { "-m", "pytest", "-v", "--tb=short" })

  local target_label = ""
  local base = file ~= "" and vim.fs.basename(file) or ""
  if exercise then
    table.insert(cmd, ".")
    target_label = " " .. vim.fs.basename(exercise)
  elseif base:match("^test_.*%.py$") or base:match(".*_test%.py$") then
    table.insert(cmd, file)
    target_label = " " .. display_path(root, file)
  end

  run_in_terminal(cmd, {
    cwd = exercise or root,
    label = ("%s -m pytest -v --tb=short%s"):format(py_label, target_label),
  })
end

function M.submit_exercism()
  local file = vim.api.nvim_buf_get_name(0)
  local exercise = exercise_root(file)
  if not exercise or vim.fn.executable("exercism") ~= 1 then
    return notify("Open an Exercism Python file and make sure the Exercism CLI is installed", vim.log.levels.WARN)
  end

  local config_path = vim.fs.joinpath(exercise, ".exercism", "config.json")
  local ok, config = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(config_path), "\n"))
  end)
  local files = ok and type(config) == "table" and config.files
  local solutions = type(files) == "table" and files.solution
  if type(solutions) ~= "table" or #solutions == 0 then
    return notify("No solution files listed in " .. config_path, vim.log.levels.ERROR)
  end
  for _, solution in ipairs(solutions) do
    if type(solution) ~= "string" or not vim.startswith(vim.fs.normalize(vim.fs.joinpath(exercise, solution)), exercise .. "/") then
      return notify("Invalid solution path in " .. config_path, vim.log.levels.ERROR)
    end
  end

  vim.ui.select({ "Test and submit", "Cancel" }, {
    prompt = "Submit " .. vim.fs.basename(exercise) .. " (" .. table.concat(solutions, ", ") .. ")?",
  }, function(choice)
    if choice ~= "Test and submit" then
      return
    end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].modified and exercise_root(vim.api.nvim_buf_get_name(buf)) == exercise then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("silent update")
        end)
      end
    end

    local python = find_python(project_root(file))
    -- Run pytest first and pass filenames as arguments to Exercism.
    local cmd = { "/bin/sh", "-c", [[
      python_count="$1"
      shift
      if [ "$python_count" -eq 3 ]; then
        "$1" "$2" "$3" -m pytest -v --tb=short . || exit "$?"
        shift 3
      else
        "$1" -m pytest -v --tb=short . || exit "$?"
        shift
      fi
      exec exercism submit "$@"
    ]], "exercise-submit", tostring(#python) }
    vim.list_extend(cmd, python)
    for _, solution in ipairs(solutions) do
      table.insert(cmd, "./" .. solution)
    end
    run_in_terminal(cmd, {
      cwd = exercise,
      label = "Test and submit " .. vim.fs.basename(exercise),
      remember = false,
    })
  end)
end

function M.run_last()
  if not last_run then
    notify("No previous Python run yet", vim.log.levels.WARN)
    return
  end
  if vim.bo.modified and vim.api.nvim_buf_get_name(0) ~= "" then
    vim.cmd("silent! update")
  end
  run_in_terminal(last_run.cmd_list, {
    cwd = last_run.cwd,
    label = last_run.label,
  })
end

return M
