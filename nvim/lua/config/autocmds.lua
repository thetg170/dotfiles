vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("IndentByFiletype", { clear = true }),
  pattern = { "yaml", "json", "markdown", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  desc = "Use deliberate-practice settings in LeetCode scratch buffers",
  group = vim.api.nvim_create_augroup("LeetCodeKata", { clear = true }),
  pattern = { "*/kata.py", "*/buggy.py" },
  callback = function(event)
    local directory = vim.fn.fnamemodify(event.file, ":p:h")
    if vim.fn.filereadable(directory .. "/meta.toml") == 0 then
      return
    end

    vim.b[event.buf].completion = false
    vim.b[event.buf].leetcode_kata = true
    vim.opt_local.colorcolumn = "100"
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("SingleWindowOnStart", { clear = true }),
  callback = function()
    local wins = vim.api.nvim_tabpage_list_wins(0)
    if #wins <= 1 then
      return
    end

    local first_buf = vim.api.nvim_win_get_buf(wins[1])
    for i = 2, #wins do
      if vim.api.nvim_win_get_buf(wins[i]) ~= first_buf then
        return
      end
    end

    vim.cmd("only")
  end,
})
