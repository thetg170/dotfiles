local keymap = vim.keymap.set

keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
keymap("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })
keymap("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

keymap({ "n", "x" }, "<leader>a", "<nop>", { desc = "+AI context" })
for suffix, entry in pairs({
  y = { "context", "Copy code + path for AI" },
  p = { "reference", "Copy file/line reference for AI" },
  e = { "explain", "Copy code + explain prompt" },
  r = { "review", "Copy code + review prompt" },
}) do
  local kind, description = entry[1], entry[2]
  keymap("n", "<leader>a" .. suffix, function()
    require("ai_context").copy(kind, false)
  end, { desc = description })
  keymap("x", "<leader>a" .. suffix, function()
    require("ai_context").copy(kind, true)
  end, { desc = description })
end

keymap("n", "<leader>k", "<nop>", { desc = "+kata" })
keymap("n", "<leader>kn", function()
  require("kata").next()
end, { desc = "Next due kata" })
keymap("n", "<leader>kp", function()
  require("kata").pick()
end, { desc = "Pick kata" })
keymap("n", "<leader>kb", function()
  require("kata").repair()
end, { desc = "Start repair kata" })
keymap("n", "<leader>kr", function()
  require("kata").test()
end, { desc = "Run kata tests" })
keymap("n", "<leader>kf", function()
  require("kata").finish()
end, { desc = "Finish and grade kata" })
keymap("n", "<leader>kd", function()
  require("kata").dashboard()
end, { desc = "Kata dashboard" })
keymap("n", "<leader>kc", function()
  require("kata").toggle_completion()
end, { desc = "Toggle kata completion" })
keymap("n", "<leader>kh", function()
  require("kata").toggle_hints()
end, { desc = "Toggle motion hints" })
keymap("n", "<leader>km", "<cmd>Hardtime report<cr>", { desc = "Hardtime motion report" })
