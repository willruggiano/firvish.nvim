---@class JobPreview
---@field job Job
---@field buffer Buffer
---@field opts table
local JobPreview = {}
JobPreview.__index = JobPreview

function JobPreview:new(job, buffer, opts)
    local obj = setmetatable({
        job = job,
        buffer = buffer,
        opts = opts,
    }, self)
    return obj
end

function JobPreview:open()
    self.buffer:open()
end

function JobPreview:make_line()
    local line = { "[" .. self.opts.job_idx .. "]", self.job:start_time(), "->", self.job:end_time() }

    if self.opts.errorlist == "quickfix" then
        table.insert(line, "[QF]")
    elseif self.opts.errorlist == "loclist" then
        table.insert(line, "[LQF]")
    end

    if self.opts.background then
        table.insert(line, "[B]")
    end

    table.insert(line, self.job.running and "[R]" or "[F]")
    if self.job.running == false then
        table.insert(line, "[E:" .. (self.job.exit_code or 0) .. "]")
    end

    local command = vim.list_extend({ self.job.job.command }, self.job.job.args)
    return table.concat(vim.list_extend(line, command), " ")
end

return JobPreview
