local ErrorList = require "firvish.internal.error_list"

---@class JobOutputBuffer
---@field buffer Buffer
---@field job Job
local JobOutputBuffer = {}
JobOutputBuffer.__index = JobOutputBuffer

---@param buffer Buffer
---@param job Job
function JobOutputBuffer:new(buffer, job)
    local obj = setmetatable({
        buffer = buffer,
        job = job,
    }, self)

    return obj:new_()
end

function JobOutputBuffer:new_()
    self.buffer:set_keymap("n", "gq", function()
        local error_list = ErrorList:new("quickfix", {
            context = {},
            title = self.buffer:name(),
        })
        self.job:add_to_error_list(error_list)
        error_list:open()
    end, { desc = "Send job output to quickfix list", noremap = true, silent = true })

    return self
end

function JobOutputBuffer:append(...)
    self.buffer:append(...)
end

function JobOutputBuffer:set_lines(...)
    self.buffer:set_lines(...)
end

function JobOutputBuffer:open()
    self.buffer:open()
end

return JobOutputBuffer
