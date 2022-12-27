local config = require "firvish.config"

local Buffer = require "firvish.internal.buffer"
local BufferList = require "firvish.internal.buffer_list"
local BufferListBuffer = require "firvish.internal.buffer_list_buffer"

local M = {}
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

M.get_buffer_list_buffer = function()
    if buffer_list_buffer == nil then
        buffer_list_buffer = BufferListBuffer:new(buffer_list)
        buffer_list_buffer:on_buf_delete(function()
            buffer_list_buffer = nil
        end)
    end
    return buffer_list_buffer
end

M.on_buf_add = function(event)
    local buffer = Buffer:new(event.buf)
    if buffer:is_same(M.get_buffer_list_buffer().buffer) == false then
        buffer_list:add(buffer)
    end
end

---@param buffer Buffer
local function should_ignore(buffer)
    local user_config = config.config
    if user_config.ignore_buffers ~= nil then
        local ignore_buffers = user_config.ignore_buffers
        if type(ignore_buffers) == "table" then
            return vim.tbl_contains(ignore_buffers.buftype or {}, buffer:get_option "buftype")
                or vim.tbl_contains(ignore_buffers.filetype or {}, buffer:filetype())
                or vim.tbl_contains(ignore_buffers.filename or {}, buffer:name())
        elseif type(ignore_buffers) == "function" then
            local ok, result = pcall(ignore_buffers, buffer)
            if ok then
                return result
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end

M.on_filetype = function(event)
    local buffer = Buffer:new(event.buf)
    local listed = buffer:listed()
    local ignore = should_ignore(buffer)
    if not listed or ignore then
        buffer_list:remove(buffer)
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
        M.get_buffer_list_buffer():filter(function(buffer)
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

return M
