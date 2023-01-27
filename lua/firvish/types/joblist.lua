---@alias JobHandle number

---@class JobList
---@field jobs table<string, Job>
---@field n number
---@field previews table<string, JobPreview>
local JobList = {}
JobList.__index = JobList

function JobList:new()
  local obj = {
    jobs = {},
    n = 0,
    previews = {},
  }
  return setmetatable(obj, self)
end

---@param pid number
---@param start_time string
local function hash(pid, start_time)
  return string.format("%s-%s", pid, start_time)
end

---@param job Job
---@param preview JobPreview
function JobList:add(job, preview)
  local key = hash(job:pid(), job:start_time())
  self.jobs[key] = job
  self.previews[key] = preview
  self.n = self.n + 1
  return key
end

---@param key string
function JobList:at(key)
  local job = self.jobs[key]
  local preview = self.previews[key]
  assert(job ~= nil, "Invalid argument: no Job for key " .. key)
  assert(preview ~= nil, "Invariant violated: no JobPreview for key " .. key)
  return job, preview
end

---@param key string
function JobList:remove(key)
  local job = self:at(key)
  self.n = self.n - 1
  self.jobs[key] = nil
  self.previews[key] = nil
  return job
end

function JobList:iter()
  return pairs(self.jobs)
end

function JobList:len()
  return self.n
end

function JobList:lines()
  local lines = {}
  for _, preview in pairs(self.previews) do
    table.insert(lines, preview:line { n = self:len() })
  end
  return lines
end

function JobList:filter(filter)
  local copy = JobList:new()
  for key, job in self:iter() do
    if filter(job) then
      copy:add(self:at(key))
    end
  end
  return copy
end

---Compute the difference between two JobLists.
---Returns a new JobList with jobs that are members of lhs
---and not members of rhs.
---@param lhs JobList
---@param rhs string[]
---@return JobList
function JobList.__div(lhs, rhs)
  local diff = JobList:new()
  for key, job in lhs:iter() do
    if rhs[key] == nil then
      diff:add(job, lhs.previews[key])
    end
  end
  return diff
end

local function hash_from(line)
  local pid, start_time = string.match(line, "%[(%d+)%] (%d+:%d+:%d+)")
  if not pid and not start_time then
    error("[firvish] Failed to parse job line '" .. line .. "'")
  end
  return hash(pid, start_time)
end

function JobList.parse(lines)
  local jobs = {}
  for _, line in ipairs(lines) do
    if line ~= "" then
      jobs[hash_from(line)] = true
    end
  end
  return jobs
end

return JobList
