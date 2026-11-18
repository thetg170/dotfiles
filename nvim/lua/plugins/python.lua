local function project_executable(root, name)
  if vim.env.DOTFILES_DEVCONTAINER == "1" then
    return
  end
  if type(root) ~= "string" then
    return
  end
  local executable = vim.fs.joinpath(root, ".venv", "bin", name)
  if vim.fn.executable(executable) == 1 then
    return executable
  end
end

local function server_command(name, args)
  return function(dispatchers, config)
    local command = { project_executable(config.root_dir, name) or name }
    vim.list_extend(command, args)
    return vim.lsp.rpc.start(command, dispatchers, {
      cwd = config.cmd_cwd or config.root_dir,
      env = config.cmd_env,
      detached = config.detached,
    })
  end
end

return {
  -- Project-local .venv discovery does not need an interactive venv picker.
  { "linux-cultist/venv-selector.nvim", enabled = false },
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
        virtual_lines = false,
      },
      inlay_hints = {
        exclude = { "vue", "python" },
      },
      servers = {
        basedpyright = {
          mason = vim.env.DOTFILES_DEVCONTAINER ~= "1",
          cmd = server_command("basedpyright-langserver", { "--stdio" }),
          handlers = {
            ["textDocument/publishDiagnostics"] = require("python_diagnostics").publish,
            ["textDocument/diagnostic"] = require("python_diagnostics").document,
          },
          settings = {
            basedpyright = {
              disableOrganizeImports = true,
              analysis = {
                -- Project configuration can opt into stricter checking.
                typeCheckingMode = "basic",
                diagnosticMode = "openFilesOnly",
              },
            },
          },
          before_init = function(_, config)
            local python = vim.env.DOTFILES_DEVCONTAINER == "1" and vim.fn.exepath("python3")
              or project_executable(config.root_dir, "python")
            if python then
              config.settings = config.settings or {}
              config.settings.python = config.settings.python or {}
              config.settings.python.pythonPath = python
            end
          end,
        },
        ruff = {
          mason = vim.env.DOTFILES_DEVCONTAINER ~= "1",
          cmd = server_command("ruff", { "server" }),
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.python = { "ruff_organize_imports", "ruff_format" }
      if vim.env.DOTFILES_DEVCONTAINER == "1" then
        return
      end
      opts.formatters = opts.formatters or {}
      for _, name in ipairs({ "ruff_format", "ruff_fix", "ruff_organize_imports" }) do
        opts.formatters[name] = vim.tbl_deep_extend("force", opts.formatters[name] or {}, {
          command = require("conform.util").find_executable({ ".venv/bin/ruff" }, "ruff"),
        })
      end
    end,
  },
}
