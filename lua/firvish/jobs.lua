local utils = require "firvish.utils"

local Buffer = require "firvish.internal.buffer"
local Job = require "firvish.internal.job"
local JobList = require "firvish.internal.job_list"
local JobListBuffer = require "firvish.internal.job_list_buffer"
local JobOutputBuffer = require "firvish.internal.job_output_buffer"
local JobPreview = require "firvish.internal.job_preview"

local lib = require "firvish.lib"

local M = {}
local job_list = JobList:new()
---@type table<number, JobPreview>
local job_previews = {}

local function not_implemented()
    assert(false, "not implemented")
end

M.open_job_list = function()
    vim.api.nvim_command [[pedit +lua\ require("firvish.jobs").on_open() firvish-jobs]]
end

local job_list_buffer

M.on_open = function()
    job_list_buffer = job_list_buffer or Buffer:new(vim.api.nvim_get_current_buf(), "[Firvish Job List]")
    local j = JobListBuffer:open(job_list_buffer, job_list, job_previews)
    job_list_buffer:on_buf_delete(function()
        job_list_buffer = nil
        j:cleanup()
    end)
end

M.refresh = function()
    not_implemented()
end

M.preview_job_output = function()
    not_implemented()
end

M.echo_job_output = function()
    not_implemented()
end

M.go_back_from_job_output = function()
    not_implemented()
end

local default_bopen_opts = {
    headers = true,
    how = "edit",
}

M.start_job = function(args)
    local bopen_opts = vim.tbl_extend("force", default_bopen_opts, type(args.bopen) == "table" and args.bopen or {})
    local is_background_job = (function()
        -- Even if args.errorlist is given, we use bopen to signify whether the job should run in
        -- the background. You could say `:Crg ...` which would open the job output buffer *and*
        -- write the results to a quickfix list.
        if type(args.bopen) == "table" then
            return false
        end

        return args.bopen == false
    end)()

    local job_idx = job_list:count() + 1
    local title = "[Firvish Job " .. job_idx .. "]"
    local buffer = Buffer:new(vim.api.nvim_create_buf(true, true), title)
    if args.filetype ~= nil then
        buffer:set_option("filetype", args.filetype)
    end

    buffer:create_autocmd({ "BufEnter", "BufWinEnter" }, {
        callback = function()
            ---@diagnostic disable-next-line: invisible
            buffer:set_lines_()
        end,
    })

    local job_opts = {
        command = args.command,
        args = args.args or {},
        cwd = args.cwd or vim.fn.getcwd(),
        on_start = function()
            if bopen_opts.headers then
                vim.schedule(function()
                    buffer:set_lines { title .. " started at " .. utils.now() }
                end)
            end
        end,
        ---@param self Job
        on_exit = function(self)
            vim.schedule(function()
                if bopen_opts.headers then
                    buffer:append(title .. " ended at " .. utils.now())
                end
                if args.errorlist then
                    local error_list = lib.errorlist.from_job_output(args.errorlist, self, {
                        context = {},
                        efm = args.efm,
                        title = title,
                    })
                    if args.eopen then
                        error_list:open()
                    end
                end
            end)
            pcall(args.on_exit, self)
        end,
        ---@diagnostic disable-next-line: unused-local
        on_stdout = function(self, data)
            if args.no_stdout ~= true then
                vim.schedule(function()
                    buffer:append(data)
                end)
            end
        end,
        ---@diagnostic disable-next-line: unused-local
        on_stderr = function(self, data)
            if args.no_stderr ~= true then
                vim.schedule(function()
                    buffer:append(data)
                end)
            end
        end,
    }
    local job = Job:new(job_opts)
    job_list:add(job)
    job:start()

    -- TODO: Not sure I like these abstractions. Namely, the JobOutputBuffer is not quite right.
    -- Consider collapsing it with the JobPreview abstraction...
    local job_output_buffer = JobOutputBuffer:new(buffer, job)
    local job_preview = JobPreview:new(job, buffer, {
        background = is_background_job,
        errorlist = args.errorlist,
        job_idx = job_idx,
    })
    job_previews[job_idx] = job_preview

    if is_background_job == false then
        buffer:open(bopen_opts.how)
    end

    return job
end

return M
