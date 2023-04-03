---@tag firvish-buffer
---@brief [[
---
---@brief ]]

local Proxy = require "firvish.types.proxy"

---@class Buffer
---@field options Proxy
local Buffer = {}

local default_opts = {
  options = {
    bufhidden = "wipe",
    buflisted = false,
    buftype = "acwrite",
    swapfile = false,
  },
}

local function make_options(bufnr)
  return Proxy.new {
    __index = function(_, name)
      local value
      vim.api.nvim_buf_call(bufnr, function()
        value = vim.opt_local[name]
      end)
      return value
    end,
    __newindex = function(_, name, value)
      vim.api.nvim_buf_call(bufnr, function()
        vim.opt_local[name] = value
      end)
    end,
  }
end

function Buffer.new(bufnr, opts)
  bufnr = bufnr or vim.api.nvim_create_buf(true, true)
  opts = opts or {}
  local obj = setmetatable({
    bufnr = bufnr,
    options = make_options(bufnr),
  }, { __index = Buffer })

  opts = vim.tbl_deep_extend("force", default_opts, opts)
  if opts.name then
    vim.api.nvim_buf_set_name(bufnr, opts.name)
  end

  vim.api.nvim_buf_call(bufnr, function()
    for key, value in pairs(opts.options or {}) do
      vim.opt_local[key] = value
    end
  end)

  return obj
end

function Buffer:create_autocmd(event, callback)
  local opts = { buffer = self.bufnr }
  if type(callback) == "function" then
    opts.callback = callback
  else
    assert(type(callback) == "table", "autocmd opts must be function or table")
    opts = vim.tbl_deep_extend("force", opts, callback)
  end
  vim.api.nvim_create_autocmd(event, opts)
end

---Get a line-range from this buffer
---@param start number?
---@param end_ number?
---@param strict_indexing boolean?
---@return string[]
---@see vim.api.nvim_buf_get_lines
function Buffer:get_lines(start, end_, strict_indexing)
  start = (start == nil) and 0 or start
  end_ = (end_ == nil) and -1 or end_
  strict_indexing = (strict_indexing == nil) and true or strict_indexing
  ---@diagnostic disable-next-line: param-type-mismatch
  return vim.api.nvim_buf_get_lines(self.bufnr, start, end_, strict_indexing)
end

---Shorthand for |nvim_buf_set_lines()|, overwriting the whole buffer contents
function Buffer:set_lines(lines)
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)
  return self
end

return Buffer
