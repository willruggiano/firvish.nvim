local config = require "firvish.config"
local utils = require "firvish.utils"

---@class JobListBuffer
---@field buffer Buffer
---@field job_list JobList
---@field job_previews table<number, JobPreview>
local JobListBuffer = {}
JobListBuffer.__index = JobListBuffer

function JobListBuffer:open(buffer, job_list, job_previews)
    buffer:set_option("buflisted", false)
    buffer:set_option("buftype", "nofile")
    buffer:set_option("bufhidden", "wipe")
    buffer:set_option("filetype", "firvish-jobs")

    local obj = setmetatable({
        buffer = buffer,
        job_list = job_list,
        job_previews = job_previews,
    }, self)

    obj:open_()

    return obj
end

function JobListBuffer:job_at(linenr)
    local idx = string.match(self.buffer:line(linenr), "%[(%d+)%]")
    idx = tonumber(idx)
    local job = self.job_list:at(idx)
    return job, idx
end

function JobListBuffer:preview_job_at(linenr)
    local _, idx = self:job_at(linenr)
    self.job_previews[idx]:open()
end

function JobListBuffer:remove_job_at(linenr, force)
    local job, idx = self:job_at(linenr)
    self.job_list:remove(idx)
    self.job_previews[idx] = nil
    if job.running and force then
        job:stop()
    end
end

function JobListBuffer:open_()
    self:refresh()
    self:set_autocmds_()
    self:set_keymaps_()
end

function JobListBuffer:cleanup()
    self:clear_autocmds_()
end

local augroup = vim.api.nvim_create_augroup("firvish-jobs", {})

function JobListBuffer:set_autocmds_()
    vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
            -- NOTE: Whenever we open the buffer, call refresh()
            self:refresh()
        end,
        group = augroup,
    })
end

function JobListBuffer:clear_autocmds_()
    vim.api.nvim_clear_autocmds { group = augroup }
end

local default_opts = { noremap = true, silent = true }

function JobListBuffer:set_keymaps_()
    self.buffer:set_keymap("n", "<CR>", function()
        self:preview_job_at(vim.fn.line ".")
    end, vim.tbl_deep_extend("force", default_opts, { desc = "Preview job under cursor " }))

    self.buffer:set_keymap("n", "dd", function()
        self:remove_job_at(vim.fn.line ".", true)
        self:refresh()
    end, vim.tbl_deep_extend("force", default_opts, { desc = "Delete job under cursor" }))

    self.buffer:set_keymap("n", "S", function()
        self:job_at(vim.fn.line "."):stop()
        self:refresh()
    end, vim.tbl_deep_extend("force", default_opts, { desc = "Stop job under cursor" }))

    self.buffer:set_keymap({ "v" }, "d", function()
        utils.exit_visual_mode()
        local line1 = vim.fn.line "'<"
        local line2 = vim.fn.line "'>"
        for linenr = line1, line2, 1 do
            self:remove_job_at(linenr, true)
        end
        self:refresh()
    end, vim.tbl_deep_extend("force", default_opts, { desc = "Delete selected jobs" }))
end

function JobListBuffer:refresh()
    self:refresh_(self.job_list, self.job_previews)
end

function JobListBuffer:refresh_(job_list, job_previews)
    local lines = {}
    for i, _ in job_list:iter() do
        table.insert(lines, job_previews[i]:make_line())
    end

    self.buffer:set_lines(lines)
end

return JobListBuffer
