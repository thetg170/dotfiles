vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/nvim")
local method = "textDocument/publishDiagnostics"
local policy = require("python_diagnostics")
local publish = policy.publish
local captured
local function capture(err, result, ctx, config)
  captured = { err = err, result = result, ctx = ctx, config = config }
end
vim.lsp.handlers[method] = capture
vim.lsp.handlers["textDocument/diagnostic"] = capture

local diagnostics = {}
for _, rule in ipairs({
  "reportUnknownArgumentType",
  "reportUnknownLambdaType",
  "reportUnknownMemberType",
  "reportUnknownParameterType",
  "reportUnknownVariableType",
}) do
  diagnostics[#diagnostics + 1] = { code = rule, severity = 2 }
end
local keep = {
  { code = "reportUnknownMemberType", severity = 1 }, -- Strict project errors survive.
  { code = "reportMissingImports", severity = 1 },
  { code = "reportUndefinedVariable", severity = 1 },
  { code = "reportArgumentType", severity = 1 },
  { code = "reportMissingParameterType", severity = 2 },
  { code = "reportUnknownMemberType", severity = 3 },
  { message = "Diagnostic without a rule", severity = 2 },
}
vim.list_extend(diagnostics, keep)
local result = { uri = "file:///test.py", version = 7, diagnostics = diagnostics }
local ctx, config = { client_id = 42 }, { underline = true }
publish(nil, result, ctx, config)
assert(vim.deep_equal(captured.result.diagnostics, keep), vim.inspect(captured))
assert(captured.result.uri == result.uri and captured.result.version == 7)
assert(captured.ctx == ctx and captured.config == config)
assert(#result.diagnostics == 12, "Must not modify the original server payload")

-- An empty publication must still reach Neovim to clear old diagnostics.
publish(nil, { uri = result.uri, diagnostics = {} }, ctx, config)
assert(#captured.result.diagnostics == 0)
local err = { code = -1, message = "fixture" }
publish(err, nil, ctx, config)
assert(captured.err == err and captured.result == nil)

-- Pull reports must keep result IDs, unchanged reports, and related documents.
local report = { kind = "full", resultId = "v1", items = diagnostics }
local unchanged = { kind = "unchanged", resultId = "v2" }
report.relatedDocuments = { ["file:///other.py"] = { kind = "full", items = diagnostics } }
policy.document(nil, report, ctx, config)
assert(vim.deep_equal(captured.result.items, keep))
assert(vim.deep_equal(captured.result.relatedDocuments["file:///other.py"].items, keep))
assert(captured.result.resultId == "v1" and #report.items == 12)
policy.document(nil, unchanged, ctx, config)
assert(vim.deep_equal(captured.result, unchanged))
policy.document(err, nil, ctx, config)
assert(captured.err == err and captured.result == nil)

local servers = dofile("nvim/lua/plugins/python.lua")[2].opts.servers
assert(servers.basedpyright.handlers[method] == publish)
assert(servers.basedpyright.handlers["textDocument/diagnostic"] == policy.document)
assert(servers.ruff.handlers == nil, "Ruff must keep its default diagnostic handler")
print("Python diagnostics passed: Unknown warnings filtered, errors/other rules retained, Ruff untouched")
