local jobs = require "firvish.lib.jobs"
local cmds = require "firvish.lib.cmds"

local lib = {}

lib.start_job = jobs.start_job

lib.create_user_command = cmds.create_user_command

return lib
