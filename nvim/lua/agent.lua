-- Send a file:line reference from Neovim to the agent pane that `dev` created.
-- Same reference format as lgtm, typed into the agent's input and never submitted.
local M = {}

-- Runs a command; returns ok, stdout. Replaced in tests.
function M.system(args)
  local result = vim.system(args, { text = true }):wait()
  return result.code == 0, vim.trim(result.stdout or "")
end

function M.range(visual)
  local current = vim.fn.line(".")
  if not visual then
    return current, current
  end
  local anchor = vim.fn.line("v")
  return math.min(anchor, current), math.max(anchor, current)
end

-- "src/app.py:12" or "src/app.py:12-20", relative to the git root.
function M.reference(buffer, first, last)
  local filename = vim.api.nvim_buf_get_name(buffer)
  if filename == "" then
    return nil
  end
  local root = vim.fs.root(filename, { ".git" }) or vim.uv.cwd()
  local path = vim.fs.relpath(root, filename) or filename
  if first == last then
    return ("%s:%d"):format(path, first)
  end
  return ("%s:%d-%d"):format(path, first, last)
end

-- The agent pane recorded by `dev`, if this Neovim runs in that tmux session.
function M.target()
  if (vim.env.TMUX or "") == "" then
    return nil
  end
  local ok, pane = M.system({ "tmux", "show-options", "-qv", "@dotfiles_agent_pane" })
  if not ok or pane == "" then
    return nil
  end
  local alive = M.system({ "tmux", "display-message", "-p", "-t", pane, "#{pane_id}" })
  return alive and pane or nil
end

function M.send(visual)
  local buffer = vim.api.nvim_get_current_buf()
  local first, last = M.range(visual)
  if visual then
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
  end
  local reference = M.reference(buffer, first, last)
  if not reference then
    vim.notify("Buffer has no file. Save it first.", vim.log.levels.WARN)
    return
  end
  -- The agent reads the file on disk, so a reference to unsaved lines would lie.
  if vim.bo[buffer].modified then
    vim.notify("Unsaved changes: :w, then send " .. reference, vim.log.levels.WARN)
    return
  end
  if vim.env.DOTFILES_HOST_BRIDGE then
    local ok, err = require("host_bridge").request("reference", reference)
    if ok then
      vim.notify("Sent " .. reference .. " to the agent")
    else
      vim.notify("Cannot reach host agent: " .. tostring(err), vim.log.levels.WARN)
    end
    return
  end
  local pane = M.target()
  if pane and M.system({ "tmux", "send-keys", "-t", pane, "-l", reference .. " " }) then
    M.system({ "tmux", "select-window", "-t", pane })
    M.system({ "tmux", "select-pane", "-t", pane })
    vim.notify("Sent " .. reference .. " to the agent")
    return
  end
  vim.fn.setreg("+", reference)
  vim.notify("No agent pane; copied " .. reference)
end

return M
