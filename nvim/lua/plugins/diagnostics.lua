return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Keep diagnostics in the gutter/underlines; Space cd opens the message.
      diagnostics = { virtual_text = false },
      inlay_hints = { enabled = false },
    },
  },
}
