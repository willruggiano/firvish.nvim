local Handle = require "plenary.job"

---@class Job
---@field job Handle
---@field data string[]
---@field stdout_ string[]
---@field stderr_ string[]
---@field errorformat string
---@field running boolean
---@field exit_code number
---@field start_time_ osdate
---@field end_time_ osdate
local Job = {}
Job.__index = Job

function Job:new(opts)
  local obj = setmetatable({
    errorformat = opts.efm or vim.api.nvim_get_option "errorformat",
    running = false,
  }, self)
  return obj:new_(opts)
end

function Job:new_(opts)
  self.handle = Handle:new {
    command = opts.command,
    args = opts.args,
    cwd = opts.cwd,
    on_stdout = function(_, data, _)
      opts.on_stdout(self, data)
    end,
    on_stderr = function(_, data, _)
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
  self.handle:start()
end

function Job:sync()
  self.handle:sync()
end

function Job:stop()
  self.handle:_stop()
end

function Job:lines()
  return self.handle:result()
end

function Job:stdout()
  return self.handle:result()
end

function Job:stderr()
  return self.handle:stderr_result()
end

local function formate_datetime(t)
  return string.format("%.2i:%.2i:%.2i", t.hour, t.min, t.sec)
end

function Job:start_time()
  return formate_datetime(self.start_time_)
end

function Job:end_time()
  if self.end_time_ ~= nil then
    return formate_datetime(self.end_time_)
  else
    return "?"
  end
end

function Job:pid()
  return self.handle.pid
end

return Job
