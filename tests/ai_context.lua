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

local directory = vim.fn.tempname()
vim.fn.mkdir(directory .. "/.git", "p")
vim.fn.mkdir(directory .. "/src", "p")
local file = directory .. "/src/example.py"
local original = { "header", "line two", "line three", "line four", "line five", "footer" }
vim.fn.writefile(original, file)
vim.cmd.edit(vim.fn.fnameescape(file))
vim.bo.filetype = "python"
vim.api.nvim_buf_set_lines(0, 2, 3, false, { 'text = "```"' })
dofile(repo .. "/nvim/lua/config/keymaps.lua")

-- Exercise a real mapping with a reversed visual selection, not stale '< marks.
vim.api.nvim_feedkeys(vim.keycode("6GV4k<Space>ae"), "xt", false)
local payload = table.concat(copied, "\n")
assert(payload:find("File: src/example.py:2-6", 1, true), payload)
assert(payload:find("unsaved buffer; disk may differ", 1, true), payload)
assert(payload:find("````python", 1, true), "Code fence should enclose embedded backticks")
assert(payload:find("Read only; do not edit files.", 1, true), payload)
assert(not payload:find("\nheader\n", 1, true), "Selection included a line outside its range")
assert(vim.bo.modified, "Copying must not save or edit the buffer")
assert(vim.deep_equal(vim.fn.readfile(file), original), "Copying changed the file on disk")

vim.api.nvim_win_set_cursor(0, { 2, 0 })
vim.api.nvim_feedkeys(vim.keycode("<Space>ap"), "xt", false)
payload = table.concat(copied, "\n")
assert(payload:find("src/example.py:2-2", 1, true), payload)
assert(not payload:find("line two", 1, true), "Reference copy should not contain source code")

vim.api.nvim_feedkeys(vim.keycode("<Space>ar"), "xt", false)
payload = table.concat(copied, "\n")
assert(payload:find("retries/idempotency", 1, true), "Missing DE review instructions")

vim.cmd.enew({ bang = true })
local text = require("ai_context").build("context", 1, 1)
assert(text:find("[No Name]:1-1", 1, true), text)
assert(text:find("unnamed buffer; not on disk", 1, true), text)
print("AI context tests passed: mappings, reversed selection, fences, unsaved buffers, references")
