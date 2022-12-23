local config = require "firvish.config"

local Buffer = require "firvish.internal.buffer"
local BufferList = require "firvish.internal.buffer_list"
local BufferListBuffer = require "firvish.internal.buffer_list_buffer"

local M = {}
local buffer_list = BufferList:new()
local buffer_list_buffer = nil

M.get_buffer_list_buffer = function()
    if buffer_list_buffer == nil then
        buffer_list_buffer = BufferListBuffer:new(buffer_list, function()
            buffer_list_buffer = nil
        end)
    end
    return buffer_list_buffer
end

---@param buffer Buffer
local function should_ignore(buffer)
    if config.ignore_buffers ~= nil then
        local ignore_buffers = config.ignore_buffers
        if type(ignore_buffers) == "table" then
            return vim.tbl_contains(ignore_buffers.filetype, buffer:get_option "filetype")
                or vim.tbl_contains(ignore_buffers.filename, buffer:name())
        elseif type(ignore_buffers) == "function" then
            return ignore_buffers(buffer)
        else
            return false
        end
    else
        return false
    end
end

---@param buffer Buffer
local function should_add_buffer(buffer)
    return buffer:listed() and not buffer:is_same(M.get_buffer_list_buffer().buffer) and not should_ignore(buffer)
end

M.on_buf_add = function(event)
    local buffer = Buffer:new(event.buf)
    if should_add_buffer(buffer) then
        buffer_list:add(buffer)
    end
end

M.on_buf_delete = function(event)
    buffer_list:remove(event.buf)
end

M.open_buffer_list = function()
    M.get_buffer_list_buffer():open()
end

M.jump_to_buffer = function()
    M.get_buffer_list_buffer():jump_to_buffer(vim.fn.line ".")
end

M.refresh_buffers = function()
    M.get_buffer_list_buffer():refresh()
end

M.delete_buffers = function(line1, line2, force)
    M.get_buffer_list_buffer():bdelete(line1, line2, force)
end

M.rename_buffer = function()
    ---@diagnostic disable-next-line: param-type-mismatch
    local bufname = vim.fn.input "> "
    M.get_buffer_list_buffer():rename_buffer(vim.fn.line ".", bufname)
end

M.filter_buffers = function(mode)
    if mode == "modified" then
        local function f(buffer)
            return buffer:modified()
        end
        M.get_buffer_list_buffer():filter(f)
    elseif mode == "current_tab" then
        local function f(buffer)
            return buffer:visible()
        end
        M.get_buffer_list_buffer():filter(f)
    elseif mode == "args" then
        local argv = vim.fn.argv()
        local buffers = {}
        for _, arg in ipairs(argv) do
            buffers[vim.fn.bufnr(arg)] = true
        end
        local function f(buffer)
            return buffers[buffer.bufnr] == true
        end
        M.get_buffer_list_buffer():filter(f)
    elseif type(mode) == "function" then
        M.get_buffer_list_buffer():filter(mode)
    else
        assert(false, "Invalid argument: unsupported filter type " .. mode)
    end
end

return M
