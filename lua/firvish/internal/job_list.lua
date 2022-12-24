---@class JobList
---@field jobs Job[]
local JobList = {}
JobList.__index = JobList

local index = 0

function JobList:new()
    local obj = {
        ---@type table<number, Job>
        jobs = {},
    }
    return setmetatable(obj, self)
end

---@param job Job
function JobList:add(job)
    self.jobs[index + 1] = job
    index = index + 1
    return self
end

function JobList:at(idx)
    local job = self.jobs[idx]
    assert(job ~= nil, "Invalid argument: no Job for index " .. idx)
    return job
end

---@param idx number
function JobList:remove(idx)
    local job = self:at(idx)
    self.jobs[idx] = nil
    return job
end

function JobList:iter()
    return pairs(self.jobs)
end

function JobList:len()
    return #self.jobs
end

function JobList:count()
    return index
end

return JobList
