return {
  {
    "tris203/precognition.nvim",
    opts = {
      startVisible = false,
    },
    event = "VeryLazy",
  },
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },
}
