local iter_bufs = require("firvish.lib.buffers").iter
local sorted_pairs = require("firvish.lib.generators").sorted_pairs

---@class BufferList
---@field buffers Buffer[]
---@field predicate fun(buffer: Buffer): boolean
local BufferList = {}
BufferList.__index = BufferList

---@param with_exising_buffers boolean
function BufferList:new(with_exising_buffers, predicate)
    local obj = setmetatable({
        buffers = {},
        predicate = predicate,
    }, self)

    if with_exising_buffers then
        obj:refresh()
    end

    return obj
end

function BufferList:refresh()
    self.buffers = {}
    for _, buffer in iter_bufs() do
        if self.predicate and self.predicate(buffer) then
            self:add(buffer)
        end
    end
    return self
end

---@param buffer Buffer
function BufferList:add(buffer)
    self.buffers[buffer.bufnr] = buffer
    return self
end

---@param buffer Buffer|number
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
    local buftype = buffer:get_option "buftype"
    if buftype == "quickfix" then
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

function BufferList:len()
    return #self.buffers
end

return BufferList
