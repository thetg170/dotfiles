-- Markdown here is mostly read: docs, agent plans, lgtm's .lgtm/review-N.md.
-- The lang.markdown extra (lazyvim.json) adds rendering, marksman and preview;
-- this file keeps it quiet: no lint noise on prose, no rewrites on save.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      -- The cursor line shows raw Markdown so editing stays exact.
      anti_conceal = { enabled = true },
      checkbox = { enabled = true },
      pipe_table = { preset = "round" },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = nil
    end,
  },
}
