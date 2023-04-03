local function if_nil(value, default)
  if value == nil then
    return default
  else
    return value
  end
end

---@class Buffer
local Buffer = {}
Buffer.__index = Buffer

Buffer.default_options = {
  bufhidden = "wipe",
  buflisted = false,
  buftype = "acwrite",
  swapfile = false,
}

function Buffer.new(listed, scratch)
  local bufnr = vim.api.nvim_create_buf(if_nil(listed, true), if_nil(scratch, true))
  for name, value in pairs(Buffer.default_options) do
    vim.api.nvim_buf_set_option(bufnr, name, value)
  end
  return Buffer.from(bufnr)
end

function Buffer.from(bufnr)
  local obj = {
    bufnr = bufnr,
    opt = setmetatable({}, {
      __index = function(_, name)
        return vim.api.nvim_buf_get_option(bufnr, name)
      end,
      __newindex = function(_, name, value)
        vim.api.nvim_buf_set_option(bufnr, name, value)
      end,
    }),
  }
  return setmetatable(obj, Buffer)
end

function Buffer:get_name(mods)
  local name = vim.fn.bufname(self.bufnr)
  if mods then
    name = vim.fn.fnamemodify(name, mods)
  end
  if name == "" then
    return "[No Name]"
  else
    return name
  end
end

function Buffer:set_name(name)
  vim.api.nvim_buf_set_name(self.bufnr, name)
end

---@class LineRange
---@field first number First line index (default: 0)
---@field last number Last line index, exclusive (default: -1)
---@field strict boolean Whether out-of-bounds should be an error

---Get a line-range from this buffer
---@param range LineRange?
---@return string[]
---@see vim.api.nvim_buf_get_lines
function Buffer:get_lines(range)
  range = range or {}
  return vim.api.nvim_buf_get_lines(
    self.bufnr,
    if_nil(range.first, 0),
    if_nil(range.last, -1),
    if_nil(range.strict, true)
  )
end

---@class ExtMark
---@field ns_id number Namespace id from |nvim_create_namespace()|
---@field line number Line where to place the mark, 0-based. |api-indexing|
---@field col number Column where to place the mark, 0-based. |api-indexing|
---@field opts ExtMarkOpts? Optional parameters

---@class ExtMarkOpts
---@field hl_group
---@field virt_text VirtText[]
---@field virt_text_pos "eol"|"overlay"|"right_align"

---@class VirtText
---@field [1] string text chunk
---@field [2] string|string[] highlight groups

---Sets (replaces) a line-range in the buffer
---@param lines string[] Array of lines to use as replacement
---@param range LineRange
---@param extmarks ExtMark[]?
---@see vim.api.nvim_buf_set_lines
function Buffer:set_lines(lines, range, extmarks)
  range = range or {}
  vim.api.nvim_buf_set_lines(
    self.bufnr,
    if_nil(range.first, 0),
    if_nil(range.last, -1),
    if_nil(range.strict, false),
    if_nil(lines, {})
  )
  if extmarks then
    for _, extmark in ipairs(extmarks) do
      vim.api.nvim_buf_set_extmark(self.bufnr, extmark.ns_id, extmark.line, extmark.col, extmark.opts)
    end
  end
  return self
end

return Buffer
