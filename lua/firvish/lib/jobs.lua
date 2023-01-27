---@mod firvish.lib.jobs The jobs api

local errorlist = require "firvish.lib.errorlist"
local lib = require "firvish.lib"

local Buffer = require "firvish.types.buffer"
local Job = require "firvish.types.job"
local JobList = require "firvish.types.joblist"
local JobPreview = require "firvish.types.jobpreview"

local jobs = {}
local job_list = JobList:new()

local default_bopen_opts = {
  headers = true,
  how = "edit",
}

---@class StartJobOpts
---@field command string
---@field args string[]
---@field cwd? string
---@field filetype? string
---@field title? string
---@field bopen? boolean|OpenBufferOpts
---@field eopen? boolean
---@field errorlist? string
---@field efm? string|string[]
---@field no_stdout? boolean
---@field no_stderr? boolean
---@field on_exit? function
---@field keep? boolean

---@class OpenBufferOpts
---@field headers? boolean
---@field how? string

---Start a job
---@param opts StartJobOpts
---@return Job
function jobs.start_job(opts)
  local bopen_opts = vim.tbl_extend("force", default_bopen_opts, type(opts.bopen) == "table" and opts.bopen or {})
  local is_background_job = (function()
    -- Even if args.errorlist is given, we use bopen to signify whether the job should run in
    -- the background. You could say `:Crg ...` which would open the job output buffer *and*
    -- write the results to a quickfix list.
    if type(opts.bopen) == "table" then
      return opts.bopen.open == false
    end

    return opts.bopen == false
  end)()

  local title = "`" .. table.concat(vim.list_extend({ opts.command }, opts.args or {}), " ") .. "`"
  local buffer = Buffer:new(vim.api.nvim_create_buf(true, true), title)
  if opts.filetype ~= nil then
    buffer:set_option("filetype", opts.filetype)
  end

  buffer:create_autocmd({ "BufEnter", "BufWinEnter" }, {
    callback = function()
      ---@diagnostic disable-next-line: invisible
      buffer:set_lines_()
    end,
  })

  local job_opts = {
    command = opts.command,
    args = opts.args or {},
    cwd = opts.cwd or vim.fn.getcwd(),
    on_start = function()
      if bopen_opts.headers then
        vim.schedule(function()
          buffer:set_lines { title .. " started at " .. lib.now() }
        end)
      end
    end,
    ---@param self Job
    on_exit = function(self)
      vim.schedule(function()
        if bopen_opts.headers then
          buffer:append(title .. " ended at " .. lib.now())
        end
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
    ---@diagnostic disable-next-line: unused-local
    on_stdout = function(self, data)
      if opts.no_stdout ~= true then
        vim.schedule(function()
          buffer:append(data)
        end)
      end
    end,
    ---@diagnostic disable-next-line: unused-local
    on_stderr = function(self, data)
      if opts.no_stderr ~= true then
        vim.schedule(function()
          buffer:append(data)
        end)
      end
    end,
  }

  local job = Job:new(job_opts)
  job:start()

  local key = job_list:add(
    job,
    JobPreview:new(job, buffer, {
      background = is_background_job,
      errorlist = opts.errorlist,
    })
  )
  if opts.keep == false then
    buffer:create_autocmd({ "BufDelete", "BufWipeout" }, {
      callback = function()
        job_list:remove(key)
      end,
    })
  end

  if is_background_job == false then
    buffer:open(bopen_opts.how)
  end

  return job
end

---Get the current joblist
---@param filter? Filter used to return a subset of jobs matching the given filter
---@return JobList
function jobs.get_joblist(filter)
  if filter then
    return job_list:filter(filter)
  else
    return job_list
  end
end

return jobs
