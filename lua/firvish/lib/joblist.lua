---@class JobList
---@field jobs Job[]
---@field previews JobPreview[]
local JobList = {}
JobList.__index = JobList

local index = 0

function JobList:new()
    local obj = {
        ---@type table<number, Job>
        jobs = {},
        ---@type table<number, JobPreview>
        previews = {},
    }
    return setmetatable(obj, self)
end

---@param job Job
---@param preview JobPreview
function JobList:add(job, preview)
    self.jobs[index + 1] = job
    self.previews[index + 1] = preview
    index = index + 1
    return self
end

function JobList:at(idx)
    local job = self.jobs[idx]
    local preview = self.previews[idx]
    assert(job ~= nil, "Invalid argument: no Job for index " .. idx)
    assert(preview ~= nil, "Invariant violated: no JobPreview for index " .. idx)
    return job, preview
end

---@param idx number
function JobList:remove(idx)
    local job = self:at(idx)
    self.jobs[idx] = nil
    self.previews[idx] = nil
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

function JobList:lines()
    local lines = {}
    for _, preview in pairs(self.previews) do
        table.insert(lines, preview:line())
    end
    return lines
end

function JobList:filter(filter)
    local copy = JobList:new()
    for i, job in self:iter() do
        if filter(job) then
            copy:add(self:at(i))
        end
    end
    return copy
end

return JobList
