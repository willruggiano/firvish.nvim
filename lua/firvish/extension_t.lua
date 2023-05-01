local Instance = require "firvish.extension_i"

---@mod firvish-extensions Firvish Extension API
---@brief [[
---
---The following method must always be implemented. It is triggered on
---the |BufEnter| and |BufWinEnter| events. It is passed a Buffer object
---which provides some abstractions for common buffer operations.
---See |firvish-buffer|.
--->
---  function Extension:on_buf_enter(buffer: Buffer)
---<
---
---When a firvish buffer has a |'buftype'| of "acwrite", the following two
---methods must also be implemented. They also accept a Buffer object as
---their only argument.
---
--->
---  function Extension:on_buf_write_cmd(buffer: Buffer)
---  function Extension:on_buf_write_post(buffer: Buffer)
---<
---
---If an extension should be executable via the |:Firvish| user command,
---the following method must be implemented. It accepts a Buffer
---object as its first argument, and a table as its second. The table
---is the same as what is passed the {command} function passed to
---|vim.api.nvim_create_user_command|.
---
--->
---  function Extension:update(args: table<string, any>)
---<
---
---@brief ]]

---@package
local Extension_t = {}
Extension_t.__index = Extension_t

---@package
function Extension_t.new(name, type, opts)
  if opts.namespace == nil then
    opts.namespace = vim.api.nvim_create_namespace("firvish-" .. name)
  end
  local obj = {
    name = name,
    type = type,
    opts = opts,
  }

  --[[
  if buffer.opt.buftype == "acwrite" then
    vim.api.nvim_create_autocmd("BufWriteCmd", {
      buffer = buffer.bufnr,
      callback = function()
        extension:on_buf_write_cmd(buffer)
      end,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
      buffer = buffer.bufnr,
      callback = function()
        extension:on_buf_write_post(buffer)
      end,
    })
  end
  --]]

  return setmetatable(obj, Extension_t)
end

function Extension_t:instance()
  if self.instance_ == nil then
    self.instance_ = Instance.new(self.type, self.opts)
    self.instance_:on({ "BufDelete", "BufWipeout" }, function()
      self.instance_ = nil
    end)
  end
  return self.instance_
end

---@package
function Extension_t:run(opts)
  -- Careful, opts.state is being passed around by reference.
  self.opts.state.opts = opts.args or {}
  self.opts.state.invert = opts.invert
  local instance = self:instance()
  instance:open(opts)
end

return Extension_t
