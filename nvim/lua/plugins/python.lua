local function project_executable(root, name)
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
      servers = {
        basedpyright = {
          cmd = server_command("basedpyright-langserver", { "--stdio" }),
          before_init = function(_, config)
            local python = project_executable(config.root_dir, "python")
            if python then
              config.settings = config.settings or {}
              config.settings.python = config.settings.python or {}
              config.settings.python.pythonPath = python
            end
          end,
        },
        ruff = {
          cmd = server_command("ruff", { "server" }),
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      for _, name in ipairs({ "ruff_format", "ruff_fix", "ruff_organize_imports" }) do
        opts.formatters[name] = vim.tbl_deep_extend("force", opts.formatters[name] or {}, {
          command = require("conform.util").find_executable({ ".venv/bin/ruff" }, "ruff"),
        })
      end
    end,
  },
}
