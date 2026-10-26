local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "LeetCode kata" })
end

local function root()
  local current = vim.api.nvim_buf_get_name(0)
  local start = current ~= "" and current or vim.uv.cwd()
  local directory = vim.fs.root(start, { ".git" })
  if directory and vim.fn.filereadable(directory .. "/tools/kata.py") == 1 then
    return directory
  end

  directory = vim.fs.root(vim.uv.cwd(), { ".git" })
  if directory and vim.fn.filereadable(directory .. "/tools/kata.py") == 1 then
    return directory
  end

  notify("Open this command inside the LeetCode repository", vim.log.levels.ERROR)
end

local function run(args, quiet)
  local cwd = root()
  if not cwd then
    return nil
  end

  local command = { "uv", "run", "--frozen", "python", "tools/kata.py" }
  vim.list_extend(command, args)
  local result = vim.system(command, { cwd = cwd, text = true }):wait()
  local output = vim.trim(result.stdout or "")
  local failure = vim.trim(result.stderr or "")
  if result.code ~= 0 then
    if not quiet then
      notify(failure ~= "" and failure or output, vim.log.levels.ERROR)
    end
    return nil, failure ~= "" and failure or output
  end
  return output, nil, cwd
end

local function run_json(args, quiet)
  local output, failure, cwd = run(args, quiet)
  if not output then
    return nil, failure
  end
  local ok, decoded = pcall(vim.json.decode, output)
  if not ok then
    notify("Cannot decode kata output: " .. output, vim.log.levels.ERROR)
    return nil, output
  end
  return decoded, nil, cwd
end

local function open_statement(session)
  if not session.statement_markdown then
    vim.cmd.edit(vim.fn.fnameescape(session.statement))
    return
  end

  local name = "kata://statement/" .. session.directory
  local buffer = vim.fn.bufnr(name)
  if buffer == -1 then
    buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buffer, name)
  end
  vim.bo[buffer].modifiable = true
  vim.api.nvim_buf_set_lines(
    buffer,
    0,
    -1,
    false,
    vim.split(session.statement_markdown, "\n", { plain = true })
  )
  vim.bo[buffer].buftype = "nofile"
  vim.bo[buffer].bufhidden = "wipe"
  vim.bo[buffer].swapfile = false
  vim.bo[buffer].filetype = "markdown"
  vim.bo[buffer].modifiable = false
  vim.api.nvim_set_current_buf(buffer)
  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  vim.wo.conceallevel = 2
end

local function open_session(session, action)
  open_statement(session)
  vim.cmd.vsplit(vim.fn.fnameescape(session.target))
  vim.cmd.wincmd("l")
  notify(("%s %s (%s)"):format(action or "Started", session.title, session.mode))
end

local function resume(problem, mode)
  local session = run_json({ "resume", problem, "--mode", mode, "--json" })
  if session then
    open_session(session, "Resumed")
  end
end

local function start(problem, mode, force)
  local args = { "start", problem, "--mode", mode, "--json" }
  if force then
    table.insert(args, "--force")
  end
  local session, failure = run_json(args, true)
  if session then
    open_session(session)
    return
  end
  if failure and failure:find("already exists", 1, true) and not force then
    vim.ui.select({ "Resume existing", "Restart from blank", "Cancel" }, {
      prompt = "A scratch file already exists",
    }, function(choice)
      if choice == "Resume existing" then
        resume(problem, mode)
      elseif choice == "Restart from blank" then
        start(problem, mode, true)
      end
    end)
    return
  end
  notify(failure or "Could not start kata", vim.log.levels.ERROR)
end

local function choose_problem(mode)
  local problems = run_json({ "list", "--all", "--json" })
  if not problems then
    return
  end
  vim.ui.select(problems, {
    prompt = mode == "repair" and "Repair kata" or "Recall kata",
    format_item = function(item)
      local patterns = #item.patterns > 0 and table.concat(item.patterns, ", ") or "unclassified"
      return ("%s  %-6s  %s  [%s]"):format(item.directory, item.difficulty, item.title, patterns)
    end,
  }, function(item)
    if item then
      start(item.directory, mode, false)
    end
  end)
end

function M.next()
  local problem = run_json({ "next", "--json" })
  if problem then
    start(problem.directory, "recall", false)
  end
end

function M.pick()
  choose_problem("recall")
end

function M.repair()
  choose_problem("repair")
end

function M.test()
  local cwd = root()
  if not cwd then
    return
  end
  local current = vim.api.nvim_buf_get_name(0)
  if current == "" then
    notify("Open a file inside a problem directory first", vim.log.levels.ERROR)
    return
  end
  Snacks.terminal({
    "uv",
    "run",
    "--frozen",
    "python",
    "tools/kata.py",
    "test",
    "--path",
    current,
  }, {
    cwd = cwd,
    interactive = false,
    auto_close = false,
    win = { position = "bottom", height = 0.35 },
  })
end

function M.finish()
  vim.ui.select({ "again", "hard", "good", "easy" }, {
    prompt = "Review grade",
  }, function(grade)
    if not grade then
      return
    end
    vim.ui.input({ prompt = "Motion focus (comma-separated): " }, function(motion_text)
      if motion_text == nil then
        return
      end
      vim.ui.input({ prompt = "Short note: " }, function(note)
        if note == nil then
          return
        end
        local args = { "finish", "--grade", grade, "--note", note, "--json" }
        for motion in motion_text:gmatch("[^,%s]+") do
          vim.list_extend(args, { "--motion", motion })
        end
        local event = run_json(args)
        if event then
          notify(("Saved %s; next review %s"):format(event.problem, event.next_due))
        end
      end)
    end)
  end)
end

function M.dashboard()
  local content = run({ "report" })
  if not content then
    return
  end
  local name = "kata://dashboard"
  local buffer = vim.fn.bufnr(name)
  if buffer == -1 then
    buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buffer, name)
  end
  vim.bo[buffer].modifiable = true
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(content, "\n", { plain = true }))
  vim.bo[buffer].filetype = "markdown"
  vim.bo[buffer].modifiable = false
  vim.api.nvim_set_current_buf(buffer)
end

function M.toggle_completion()
  vim.b.completion = vim.b.completion == false
  notify("Completion " .. (vim.b.completion and "enabled" or "disabled") .. " for this buffer")
end

function M.toggle_hints()
  local ok, precognition = pcall(require, "precognition")
  if not ok then
    notify("precognition.nvim is not available", vim.log.levels.ERROR)
    return
  end
  local was_visible = precognition.toggle()
  notify("Motion hints " .. (was_visible and "hidden" or "shown"))
end

return M
