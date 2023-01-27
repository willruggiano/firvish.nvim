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

function JobPreview:open(how)
  self.buffer:open(how)
end

function JobPreview:line(opts)
  -- No matter what index you are, you always get one space of padding
  -- You also get the difference between you and the max
  -- local sep = 1 + #tostring(opts.n) - #tostring(self.job:pid())
  local sep = 1
  local line = {
    "[" .. self.job:pid() .. "]" .. string.rep(" ", sep) .. self.job:start_time(),
    "->",
    self.job:end_time(),
  }

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

  local command = vim.list_extend({ self.job.handle.command }, self.job.handle.args)
  return table.concat(vim.list_extend(line, command), " ")
end

return JobPreview
