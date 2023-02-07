---@class Config
---@field keymaps table

local config = {}

config.global = {
  commands = {},
  keymaps = {
    n = {
      ["-"] = {
        callback = function()
          vim.cmd.bwipeout()
        end,
        desc = "Close the firvish buffer",
      },
    },
  },
}

config.plugin = setmetatable({}, {
  __index = function()
    return {
      commands = {},
      keymaps = {},
    }
  end,
})

local function apply_commands(bufnr, commands)
  for name, opts in pairs(vim.deepcopy(commands)) do
    local command = assert(opts.command, "commands must have a command")
    opts.command = nil
    vim.api.nvim_buf_create_user_command(bufnr, name, command, opts)
  end
end

local function apply_keymaps(bufnr, keymaps)
  local default_opts = { buffer = bufnr, noremap = true, silent = true }
  for mode, mappings in pairs(keymaps) do
    for lhs, opts in pairs(mappings) do
      if opts then
        opts = vim.deepcopy(opts)
        local callback = assert(opts.callback, "must have a callback")
        opts.callback = nil
        vim.keymap.set(mode, lhs, callback, vim.tbl_extend("force", default_opts, opts))
      end
    end
  end
end

local function apply_config(bufnr, cfg)
  apply_commands(bufnr, cfg.commands)
  apply_keymaps(bufnr, cfg.keymaps)
end

---Apply configuration, globally or plugin specific
---@param opts table
---@param plugin string?
function config.apply(opts, plugin)
  vim.validate {
    opts = { opts, "table" },
    plugin = { plugin, "string", true },
  }

  if plugin then
    config.plugin[plugin] = vim.tbl_deep_extend("force", config.plugin[plugin], opts)
  else
    config.global = vim.tbl_deep_extend("force", config.global, opts)
  end
end

function config.setup_buffer(bufnr, plugin, noglobal)
  vim.validate {
    bufnr = { bufnr, "number" },
    plugin = { plugin, "string" },
    noglobal = { noglobal, "boolean", true },
  }

  apply_config(bufnr, config.plugin[plugin])
  if noglobal ~= true then
    apply_config(bufnr, config.global)
  end
end

return config
