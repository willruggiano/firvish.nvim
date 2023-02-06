local StringBuffer = {}
StringBuffer.__index = StringBuffer

function StringBuffer.new(opts)
  local obj = vim.tbl_extend("keep", opts or {}, {
    lines = {},
    options = {},
  })
  return setmetatable(obj, StringBuffer)
end

function StringBuffer:append(line)
  table.insert(self.lines, line)
  return self
end

---@diagnostic disable-next-line: unused-vararg
function StringBuffer:create_autocmd(...)
  return self
end

---@diagnostic disable-next-line: unused-vararg
function StringBuffer:open(...)
  return self
end

function StringBuffer:set_lines(lines)
  self.lines = lines
end

function StringBuffer:set_option(key, value)
  self.options[key] = value
end

return StringBuffer
