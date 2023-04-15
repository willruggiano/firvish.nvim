local Buffer = require "firvish.buffer2"
local utils = require "firvish.utils"

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
local Extension = {}
Extension.__index = Extension

---@package
function Extension.new(name, extension)
  local buffer = Buffer.new()
  local obj = {
    buffer = buffer,
    extension = extension,
    name = name,
  }

  if extension.bufname then
    buffer:set_name(extension.bufname)
  end

  utils.apply_keymaps(buffer.bufnr, extension.keymaps or {})
  utils.apply_options(buffer.bufnr, extension.options or {})

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    buffer = buffer.bufnr,
    callback = function()
      extension:on_buf_enter(buffer)
    end,
  })

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

  return setmetatable(obj, Extension)
end

---@package
function Extension:__call(args)
  if self.extension.execute then
    self.extension:execute(self.buffer, args or {})
  end
end

return Extension
