---@mod firvish.lib.errorlist The errorlist API
---@brief [[
---
---@brief ]]

local ErrorList = require "firvish.internal.error_list"

local errorlist = {}

---Create an errorlist from a table of lines.
---@param what string the type of errorlist to open; [quickfix|loclist]
---@param lines string[] lines to send to the errorlist
---@param opts? table
function errorlist.from_lines(what, lines, opts)
    local error_list = ErrorList:new(what, opts or {})
    error_list:set {
        lines = lines,
    }
    return error_list
end

local function get_efm(buffer)
    local _, buf_efm = pcall(vim.api.nvim_buf_get_option, buffer.bufnr, "errorformat")
    if buf_efm ~= nil and buf_efm ~= "" then
        return buf_efm
    end

    local _, vim_efm = pcall(vim.api.nvim_get_option, "errorformat")
    if vim_efm ~= nil and vim_efm ~= "" then
        return vim_efm
    end

    return ""
end

---Create an errorlist from a buffer.
---@param what string the type of errorlist to open; [quickfix|loclist]
---@param buffer Buffer buffer to get quickfix lines from
---@param opts? table
function errorlist.from_buflines(what, buffer, opts)
    local error_list = ErrorList:new(what, vim.tbl_extend("keep", opts or {}, { efm = get_efm(buffer) }))
    error_list:set {
        lines = buffer:get_lines(),
    }
    return error_list
end

---Create an errorlist from a range of buffer lines.
---@param what string the type of errorlist to open; [quickfix|loclist]
---@param buffer Buffer buffer to get quickfix lines from
---@param line1 number line range start index
---@param line2 number line range end index
---@param opts? table
function errorlist.from_bufrange(what, buffer, line1, line2, opts)
    local eopts = vim.tbl_extend("keep", opts or {}, { efm = get_efm(buffer) })
    local error_list = ErrorList:new(what, eopts)
    error_list:set {
        lines = buffer:get_lines(line1, line2, false),
    }
    return error_list
end

---Create an errorlist from a Job's output.
---@param what string the type of errorlist to open; [quickfix|loclist]
---@param job Job job to get quickfix lines from
---@param opts? table
function errorlist.from_job_output(what, job, opts)
    local error_list = ErrorList:new(what, opts or {})
    error_list:set {
        lines = job:lines(),
    }
    return error_list
end

return errorlist
