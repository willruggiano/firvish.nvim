local sorted_pairs = require("firvish.utils").sorted_pairs

---@class BufferList
---@field buffers Buffer[]
local BufferList = {}
BufferList.__index = BufferList

function BufferList:new()
    local obj = {
        buffers = {},
    }
    return setmetatable(obj, self)
end

function BufferList:add(buffer)
    self.buffers[buffer.bufnr] = buffer
    return self
end

function BufferList:remove(buffer)
    if type(buffer) == "number" then
        self.buffers[buffer] = nil
    else
        self.buffers[buffer.bufnr] = nil
    end
    return self
end

---Create a new BufferList using only the buffers which satisfy a given predicate
---@param f function a predicate which returns `false` to filter out a buffer
function BufferList:filter(f)
    local copy = BufferList:new()
    for _, buffer in pairs(self.buffers) do
        if f(buffer) then
            copy:add(buffer)
        end
    end
    return copy
end

---@param buffer Buffer
local function make_buffer_line(buffer)
    local line = "[" .. buffer.bufnr .. "]"
    if buffer:modified() then
        line = line .. " +"
    end
    local bufname = buffer:name()
    if bufname == "" then
        bufname = "[No Name]"
    end
    line = line .. " " .. bufname
    local filetype = buffer:filetype()
    if filetype == "qf" then
        line = line .. " (quickfix)"
    end
    return line
end

function BufferList:lines()
    local lines = {}
    for _, buffer in pairs(self:sorted()) do
        table.insert(lines, make_buffer_line(buffer))
    end
    return lines
end

function BufferList:sorted()
    local buffers = {}
    for _, buffer in sorted_pairs(self.buffers) do
        table.insert(buffers, buffer)
    end
    return buffers
end

return BufferList
