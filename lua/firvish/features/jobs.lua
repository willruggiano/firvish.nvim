---@mod firvish.jobs Jobs
---@tag :FirvishJobs
---@brief [[
---Job stuff
---@brief ]]

local jobctrl = require "firvish.jobs"

local jobs = {}

---@package
function jobs.setup()
    vim.api.nvim_create_user_command("FirvishJobs", jobctrl.open_job_list, { bar = true })
end

return jobs
