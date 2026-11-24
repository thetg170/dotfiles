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
  {
    "mfussenegger/nvim-dap-python",
    opts = function()
      local dap_python = require("dap-python")
      dap_python.test_runner = "pytest"
      dap_python.resolve_python = function()
        local file = vim.api.nvim_buf_get_name(0)
        local start = file ~= "" and file or vim.uv.cwd()
        local root = vim.fs.root(start, { "pyproject.toml", ".venv", ".git" }) or vim.uv.cwd()
        local venv_python = project_executable(root, "python")
        if venv_python then
          return venv_python
        end
        if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
          local active = vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
          if vim.fn.executable(active) == 1 then
            return active
          end
        end
        return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
      end
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.45 },
            { id = "breakpoints", size = 0.2 },
            { id = "stacks", size = 0.2 },
            { id = "watches", size = 0.15 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = {
            { id = "console", size = 0.65 },
            { id = "repl", size = 0.35 },
          },
          size = 14,
          position = "bottom",
        },
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      -- Keep DAP UI open after exit so final logs and tracebacks remain visible.
      -- Close manually with <leader>du.
      dap.listeners.before.event_terminated["dapui_config"] = nil
      dap.listeners.before.event_exited["dapui_config"] = nil
    end,
  },
}
