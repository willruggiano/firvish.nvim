---@mod firvish.buffers Buffers
---@brief [[
---Lua API for interacting with the |firvish-buffers| list.
---@brief ]]

local Buffer = require "firvish.internal.buffer"
local BufferList = require "firvish.internal.buffer_list"
local BufferListBuffer = require "firvish.internal.buffer_list_buffer"

local buffers = {}

local buffer_list = (function()
    local buffer_list = BufferList:new()
    -- NOTE: This accounts for initial buffers created during startup
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        local buffer = Buffer:new(bufnr)
        if buffer:listed() then
            buffer_list:add(buffer)
        end
    end
    return buffer_list
end)()
local buffer_list_buffer = nil

function buffers.get_buffer_list_buffer()
    if buffer_list_buffer == nil then
        buffer_list_buffer = BufferListBuffer:new(buffer_list)
        buffer_list_buffer:on_buf_delete(function()
            buffer_list_buffer = nil
        end)
    end
    return buffer_list_buffer
end

---@private
function buffers.on_buf_add(event)
    local buffer = Buffer:new(event.buf)
    if buffer:is_same(buffers.get_buffer_list_buffer().buffer) == false then
        buffer_list:add(buffer)
    end
end

---@private
function buffers.on_filetype(event)
    -- local buffer = Buffer:new(event.buf)
    -- local listed = buffer:listed()
    -- local ignore = should_ignore(buffer)
    -- if not listed or ignore then
    --     buffer_list:remove(buffer)
    -- end
end

---@private
function buffers.on_buf_delete(event)
    buffer_list:remove(event.buf)
end

function buffers.open_buffer_list(opts)
    local buffer = buffers.get_buffer_list_buffer()
    buffer:open(opts.how)
    return buffer
end

function buffers.jump_to_buffer()
    buffers.get_buffer_list_buffer():jump_to_buffer(vim.fn.line ".")
end

function buffers.refresh_buffers()
    buffers.get_buffer_list_buffer():refresh()
end

function buffers.delete_buffers(line1, line2, force)
    buffers.get_buffer_list_buffer():bdelete(line1, line2, force)
end

function buffers.rename_buffer()
    ---@diagnostic disable-next-line: param-type-mismatch
    local bufname = vim.fn.input "> "
    buffers.get_buffer_list_buffer():rename_buffer(vim.fn.line ".", bufname)
end

function buffers.filter_buffers(mode)
    if mode == "modified" then
        local function f(buffer)
            return buffer:modified()
        end
        buffers.get_buffer_list_buffer():filter(f)
    elseif mode == "visible" then
        local function f(buffer)
            return buffer:visible()
        end
        buffers.get_buffer_list_buffer():filter(f)
    elseif mode == "args" then
        local argv = vim.fn.argv()
        local buffers_ = {}
        for _, arg in ipairs(argv) do
            buffers_[vim.fn.bufnr(arg)] = true
        end
        local function f(buffer)
            return buffers_[buffer.bufnr] == true
        end
        buffers_.get_buffer_list_buffer():filter(f)
    elseif type(mode) == "function" then
        buffers.get_buffer_list_buffer():filter(function(buffer)
            local ok, result = pcall(mode, buffer)
            if ok then
                return result
            else
                return false
            end
        end)
    else
        assert(false, "Invalid argument: unsupported filter type " .. mode)
    end
end

return buffers
