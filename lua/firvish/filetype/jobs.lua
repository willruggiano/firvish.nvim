---@mod firvish.filetype.jobs
---@brief [[
---The buffer-local library which is passed to keymaps associated with the |firvish-jobs|
---filetype.
---@brief ]]

local Buffer = require "firvish.internal.buffer"

local lines = require "firvish.lib.lines"

local generic = require "firvish.filetype.generic"
local lib = {
    close = generic.close,
    open_alternate_file = generic.open_alternate_file,
}

---@package
function lib.setup(bufnr)
    -- Setup buffer-local features
    local buffer = Buffer:new(bufnr)
    buffer:set_options {
        bufhidden = "wipe",
        buflisted = false,
        -- TODO: acwrite; make the job list buffer just a normal buffer
        buftype = "nofile",
        swapfile = false,
    }

    local config = require("firvish.features.jobs").config
    local default_opts = { buffer = bufnr, noremap = true, silent = true }
    for mode, mappings in pairs(config.keymaps) do
        for lhs, opts in pairs(mappings) do
            if opts then
                vim.keymap.set(mode, lhs, function()
                    opts.callback(lib)
                end, vim.tbl_extend("force", default_opts, opts))
            end
        end
    end

    -- Display the job-list
    lib.refresh(buffer)

    -- Make it so whenever we enter the buffer the job-list gets refreshed
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        buffer = bufnr,
        callback = function()
            lib.refresh(buffer)
        end,
    })
end

---Refresh the job list
---@param buffer? Buffer
function lib.refresh(buffer)
    if buffer == nil then
        buffer = Buffer:new(vim.api.nvim_get_current_buf())
    end
    local joblist = require("firvish.lib.jobs").jobs()
    buffer:set_lines(joblist:lines())
    buffer:set_option("modified", false)
end

---Preview the output of the job at the current cursor position
---@param how? string how to open the buffer, e.g. `:edit`, `:split`, `:vert pedit`, etc
function lib.preview_job(how)
    local _, preview = lib.job_at_cursor()
    vim.cmd.pclose()
    preview:open(how)
end

---Get the Job at the current cursor position
---@return Job, JobPreview
function lib.job_at_cursor()
    local line = lines.get_cursor_line()
    return lib.job_at_line(line)
end

---@package
---@return Job, JobPreview
function lib.job_at_line(line)
    local job_idx = lib.parse_line(line)
    -- TODO: This is kind of problematic.
    -- See lua/firvish/features/jobs.lua and the "g." keymap
    local joblist = require("firvish.lib.jobs").jobs()
    return joblist:at(job_idx)
end

---@package
function lib.parse_line(line)
    local match = string.match(line, "%[(%d+)%]")
    if match ~= nil then
        return tonumber(match)
    else
        error("[firvish] Failed to get job from '" .. line .. "'")
    end
end

return lib
