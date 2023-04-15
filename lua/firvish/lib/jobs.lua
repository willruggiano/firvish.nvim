---@mod firvish.lib.jobs The jobs api

local errorlist = require "firvish.lib.errorlist"

local Buffer = require "firvish.types.buffer"
local Job = require "firvish.types.job"

local jobs = {}
---@type {string: Job}
local jobinfo = {}

---@class StartJobOpts
---@field command string
---@field args string[]
---@field cwd? string
---@field filetype? string
---@field title? string
---@field bopen? boolean|string
---@field eopen? boolean
---@field errorlist? boolean|string
---@field efm? string|string[]
---@field no_stdout? boolean
---@field no_stderr? boolean
---@field on_exit? function
---@field keep? boolean

local function make_buffer(title)
  return Buffer:new(vim.api.nvim_create_buf(true, true), title)
end

local count = 0

---Start a job
---@param opts StartJobOpts
---@return Job
function jobs.start_job(opts)
  count = count + 1
  local title = "[Job #"
    .. count
    .. "] `"
    .. table.concat(vim.list_extend({ opts.command }, opts.args or {}), " ")
    .. "`"
  local buffer = opts.buffer or make_buffer(title)

  if opts.filetype ~= nil then
    buffer:set_option("filetype", opts.filetype)
  end

  buffer:create_autocmd({ "BufEnter", "BufWinEnter" }, {
    callback = function()
      ---@diagnostic disable-next-line: invisible
      buffer:set_lines_()
    end,
  })

  local on_stdout = (function()
    if opts.on_stdout == nil then
      return function(self, data)
        vim.schedule(function()
          buffer:append(data)
        end)
      end
    elseif opts.on_stdout == false then
      return function() end
    else
      return function(self, data)
        vim.schedule(function()
          opts.on_stdout(self, data)
        end)
      end
    end
  end)()

  local on_stderr = (function()
    if opts.on_stderr == nil then
      return function(self, data)
        vim.schedule(function()
          buffer:append(data)
        end)
      end
    elseif opts.on_stderr == false then
      return function() end
    else
      return function(self, data)
        vim.schedule(function()
          opts.on_stderr(self, data)
        end)
      end
    end
  end)()

  local job_opts = {
    command = opts.command,
    args = opts.args or {},
    cwd = opts.cwd or vim.fn.getcwd(),
    on_start = function()
      pcall(opts.on_start, buffer)
    end,
    ---@param self Job
    on_exit = function(self)
      vim.schedule(function()
        if opts.errorlist then
          local error_list = errorlist.from_job_output(opts.errorlist, self, {
            context = {},
            efm = opts.efm,
            title = title,
          })
          if opts.eopen then
            error_list:open()
          end
        end
        pcall(opts.on_exit, self, buffer)
      end)
    end,
    on_stdout = on_stdout,
    on_stderr = on_stderr,
  }

  local job = Job.new(count, job_opts)
  job:start()

  jobinfo[tostring(job.id)] = job
  if opts.keep == false then
    buffer:create_autocmd({ "BufDelete", "BufWipeout" }, {
      callback = function()
        jobinfo[tostring(job.id)] = nil
      end,
    })
  end

  if type(opts.bopen) == "string" then
    buffer:open(opts.bopen)
  elseif opts.bopen == true then
    buffer:open()
  end

  return job
end

---@param id number?
function jobs.getjobinfo(id)
  if id then
    return { jobinfo[tostring(id)] }
  else
    return vim.tbl_values(jobinfo)
  end
end

function jobs.delete_job(id)
  -- TODO: Stop, if running
  jobinfo[tostring(id)] = nil
end

return jobs
