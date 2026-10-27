if vim.env.DOTFILES_HOST_BRIDGE then
  require("host_bridge").setup_clipboard()
end

-- Treat `nvim .` / `nvim path/to/project` as a project cwd, without opening
-- a directory buffer (which automatically launches the explorer).
if vim.fn.argc() == 1 then
  local directory = vim.fn.argv(0)
  if vim.fn.isdirectory(directory) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.fnamemodify(directory, ":p"))
    vim.cmd("argdelete *")
    vim.api.nvim_buf_set_name(0, "")
  end
end

require("config.lazy")
