local Handle = require "plenary.job"

---@class Job
---@field job Handle
---@field data string[]
---@field errorformat string
---@field running boolean
---@field exit_code number
---@field start_time_ osdate
---@field end_time_ osdate
local Job = {}
Job.__index = Job

function Job:new(opts)
    local obj = setmetatable({
        data = {},
        errorformat = opts.efm or vim.api.nvim_get_option "errorformat",
        running = false,
    }, self)
    return obj:new_(opts)
end

function Job:new_(opts)
    self.job = Handle:new {
        command = opts.command,
        args = opts.args,
        cwd = opts.cwd,
        on_stdout = function(_, data, _)
            table.insert(self.data, data)
            opts.on_stdout(self, data)
        end,
        on_stderr = function(_, data, _)
            table.insert(self.data, data)
            opts.on_stderr(self, data)
        end,
        on_start = function()
            ---@diagnostic disable-next-line: assign-type-mismatch
            self.start_time_ = os.date "*t"
            self.running = true
            opts.on_start(self)
        end,
        on_exit = function(_, code, _)
            ---@diagnostic disable-next-line: assign-type-mismatch
            self.end_time_ = os.date "*t"
            self.exit_code = code
            self.running = false
            opts.on_exit(self)
        end,
    }
    return self
end

function Job:start()
    self.job:start()
end

function Job:stop()
    self.job:_stop()
end

function Job:lines()
    return self.data
end

function Job:start_time()
    local t = self.start_time_
    return string.format("%s:%s:%s", t.hour, t.min, t.sec)
end

function Job:end_time()
    if self.end_time_ ~= nil then
        local t = self.end_time_
        return string.format("%s:%s:%s", t.hour, t.min, t.sec)
    else
        return "?"
    end
end

---Add the Job output to an errorlist (quickfix or loclist).
---@param error_list ErrorList
function Job:add_to_error_list(error_list)
    error_list:set {
        lines = self:lines(),
    }
end

return Job
