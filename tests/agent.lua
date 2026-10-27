local repo = vim.fn.getcwd()
vim.opt.runtimepath:prepend(repo .. "/nvim")
vim.g.mapleader = " "

-- Keep the real macOS clipboard untouched during tests.
local copied = {}
vim.g.clipboard = {
  name = "workflow-test",
  copy = {
    ["+"] = function(lines)
      copied = lines
    end,
    ["*"] = function() end,
  },
  paste = {
    ["+"] = function()
      return { copied, "v" }
    end,
    ["*"] = function()
      return { {}, "v" }
    end,
  },
  cache_enabled = 0,
}

-- Fake tmux: record every call, never touch a real server.
local agent = require("agent")
local calls, panes = {}, { ["%7"] = true }
agent.system = function(args)
  calls[#calls + 1] = table.concat(args, " ")
  if args[2] == "show-options" then
    return true, "%7"
  elseif args[2] == "display-message" then
    return panes[args[5]] == true, args[5]
  end
  return true, ""
end
local function sent()
  for _, call in ipairs(calls) do
    local text = call:match("^tmux send%-keys %-t %%7 %-l (.*)$")
    if text then
      return text
    end
  end
end
local function reset()
  calls, copied = {}, {}
end

local directory = vim.fn.tempname()
vim.fn.mkdir(directory .. "/.git", "p")
vim.fn.mkdir(directory .. "/src", "p")
local file = directory .. "/src/example.py"
local original = { "header", "line two", "line three", "line four", "line five", "footer" }
vim.fn.writefile(original, file)
vim.cmd.edit(vim.fn.fnameescape(file))
dofile(repo .. "/nvim/lua/config/keymaps.lua")
vim.env.TMUX = "/tmp/fake,1,0"

-- A reversed visual selection, not stale '< marks.
reset()
vim.api.nvim_feedkeys(vim.keycode("6GV4k<Space>a"), "xt", false)
assert(sent() == "src/example.py:2-6 ", vim.inspect(calls))
assert(vim.tbl_contains(calls, "tmux select-pane -t %7"), "Should focus the agent pane")
assert(not vim.tbl_contains(calls, "tmux send-keys -t %7 Enter"), "Must never submit")
assert(vim.fn.mode() == "n", "Visual mode should end after sending")

reset()
vim.api.nvim_win_set_cursor(0, { 3, 0 })
vim.api.nvim_feedkeys(vim.keycode("<Space>a"), "xt", false)
assert(sent() == "src/example.py:3 ", vim.inspect(calls))

-- Container Neovim sends through the host bridge, without a tmux socket inside.
local bridge = require("host_bridge")
local bridge_calls = {}
local original_request = bridge.request
bridge.request = function(action, text)
  bridge_calls[#bridge_calls + 1] = { action, text }
  return { ok = true }
end
vim.env.DOTFILES_HOST_BRIDGE = "/fixture/bridge"
reset()
vim.api.nvim_feedkeys(vim.keycode("<Space>a"), "xt", false)
assert(vim.deep_equal(bridge_calls, { { "reference", "src/example.py:3" } }))
assert(#calls == 0, "Container mode must not call tmux inside the container")
vim.env.DOTFILES_HOST_BRIDGE = nil
bridge.request = original_request

-- Unsaved lines: the agent would read different code from disk, so nothing goes out.
reset()
vim.api.nvim_buf_set_lines(0, 0, 1, false, { "changed" })
vim.api.nvim_feedkeys(vim.keycode("<Space>a"), "xt", false)
assert(sent() == nil and #copied == 0, "Unsaved buffer must not be sent")
assert(vim.deep_equal(vim.fn.readfile(file), original), "Sending must never write the file")
vim.cmd("silent write")

-- No agent pane (old session, closed pane, or outside tmux): fall back to the clipboard.
reset()
panes["%7"] = nil
vim.api.nvim_feedkeys(vim.keycode("<Space>a"), "xt", false)
assert(sent() == nil, vim.inspect(calls))
assert(table.concat(copied, "\n") == "src/example.py:3", vim.inspect(copied))

reset()
panes["%7"] = true
vim.env.TMUX = nil
vim.api.nvim_feedkeys(vim.keycode("<Space>a"), "xt", false)
assert(#calls == 0 and table.concat(copied, "\n") == "src/example.py:3", vim.inspect(calls))

reset()
vim.cmd.enew({ bang = true })
vim.env.TMUX = "/tmp/fake,1,0"
vim.api.nvim_feedkeys(vim.keycode("<Space>a"), "xt", false)
assert(#calls == 0 and #copied == 0, "Unnamed buffer must not be sent")

print("Agent tests passed: reversed selection, single line, no Enter, unsaved, missing pane, outside tmux, unnamed")
