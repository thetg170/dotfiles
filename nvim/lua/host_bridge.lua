local M = {}
local serial = 0

function M.request(action, text)
  local directory = vim.env.DOTFILES_HOST_BRIDGE
  if not directory or vim.fn.isdirectory(directory) == 0 then
    return nil, "Host bridge is unavailable"
  end
  serial = serial + 1
  local stem = ("%s/%d-%d"):format(directory, vim.fn.getpid(), serial)
  local ok, err = pcall(function()
    vim.fn.writefile({ vim.json.encode({ action = action, text = text }) }, stem .. ".tmp")
    assert(vim.uv.fs_rename(stem .. ".tmp", stem .. ".request"))
  end)
  if not ok then
    return nil, tostring(err)
  end
  if not vim.wait(3000, function()
    return vim.fn.filereadable(stem .. ".response") == 1
  end, 20) then
    vim.fn.delete(stem .. ".request")
    return nil, "Host bridge timed out"
  end
  local response = vim.json.decode(table.concat(vim.fn.readfile(stem .. ".response"), "\n"))
  vim.fn.delete(stem .. ".response")
  return response.ok and response or nil, response.error
end

function M.setup_clipboard()
  local function copy(lines)
    local ok, err = M.request("copy", table.concat(lines, "\n"))
    if not ok then
      vim.notify(err, vim.log.levels.WARN)
    end
  end
  local function paste()
    local response = M.request("paste")
    return { vim.split(response and response.text or "", "\n", { plain = true }), "v" }
  end
  vim.g.clipboard = {
    name = "macOS via devcontainer bridge",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
    cache_enabled = 0,
  }
end

return M
