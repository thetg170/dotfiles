if vim.env.DOTFILES_HOST_BRIDGE then
  require("host_bridge").setup_clipboard()
end
require("config.lazy")
