local M = {}

local unknown_rules = {
  reportUnknownArgumentType = true,
  reportUnknownLambdaType = true,
  reportUnknownMemberType = true,
  reportUnknownParameterType = true,
  reportUnknownVariableType = true,
}

-- Project configs can override the LSP's typeCheckingMode. Keep this personal
-- display preference in Neovim without changing the project's CLI/CI checks.
local function filter(diagnostics)
  return vim.tbl_filter(function(diagnostic)
    return not (diagnostic.severity == vim.lsp.protocol.DiagnosticSeverity.Warning and unknown_rules[diagnostic.code])
  end, diagnostics)
end

local function document(report)
  local copy = vim.tbl_extend("force", {}, report)
  if report.kind == "full" then
    copy.items = filter(report.items)
  end
  if report.relatedDocuments then
    copy.relatedDocuments = vim.tbl_map(document, report.relatedDocuments)
  end
  return copy
end

function M.publish(err, result, ctx, config)
  if result and result.diagnostics then
    result = vim.tbl_extend("force", result, { diagnostics = filter(result.diagnostics) })
  end
  return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
end

-- Newer Basedpyright/Neovim versions use pull diagnostics, including dynamic
-- registration; handling publishDiagnostics alone does not cover these.
function M.document(err, result, ctx, config)
  return vim.lsp.handlers["textDocument/diagnostic"](err, result and document(result), ctx, config)
end

return M
