local M = {}

local prompts = {
  explain = "Read only; do not edit files. Explain this code's inputs, outputs, side effects, "
    .. "callers, and error cases. Trace one example input. Point to relevant tests and file:line "
    .. "references. Distinguish confirmed behavior from assumptions.",
  review = "Read only; do not edit files. Review this code and its callers for concrete bugs, "
    .. "regressions, and missing tests. For data pipelines, check retries/idempotency, nulls, "
    .. "schema/timezone handling, transactions/checkpoints, and memory use. Prioritize findings "
    .. "with file:line references, impact, and a reproducer or test idea. Avoid style-only feedback.",
}

function M.range(visual)
  local current = vim.fn.line(".")
  if not visual then
    return current, current
  end
  local anchor = vim.fn.line("v")
  return math.min(anchor, current), math.max(anchor, current)
end

function M.build(kind, first, last)
  local buffer = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(buffer)
  local root = filename ~= "" and vim.fs.root(filename, { ".git" }) or nil
  root = root or vim.uv.cwd()
  local path = filename ~= "" and (vim.fs.relpath(root, filename) or filename) or "[No Name]"
  local reference = ("%s:%d-%d"):format(path, first, last)
  local source = filename == "" and "unnamed buffer; not on disk"
    or (vim.bo[buffer].modified and "unsaved buffer; disk may differ" or "saved buffer")
  local parts = { "Project: " .. root, "File: " .. reference, "Source: " .. source }

  if kind ~= "reference" then
    local code = table.concat(vim.api.nvim_buf_get_lines(buffer, first - 1, last, false), "\n")
    local width = 3
    for ticks in code:gmatch("`+") do
      width = math.max(width, #ticks + 1)
    end
    local fence = string.rep("`", width)
    parts[#parts + 1] = "\n" .. fence .. vim.bo[buffer].filetype .. "\n" .. code .. "\n" .. fence
  else
    parts[#parts + 1] = "\nRead this file from the project. Save the buffer first if it is modified."
  end
  if prompts[kind] then
    parts[#parts + 1] = "\n" .. prompts[kind]
  end
  return table.concat(parts, "\n"), reference
end

function M.copy(kind, visual)
  local first, last = M.range(visual)
  local text, reference = M.build(kind, first, last)
  local ok, error = pcall(vim.fn.setreg, "+", text, "v")
  if not ok then
    vim.notify("Cannot copy AI context: " .. tostring(error), vim.log.levels.ERROR)
    return
  end
  if visual then
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
  end
  vim.notify("Copied " .. reference .. ". Paste into AI and add your question.")
end

return M
