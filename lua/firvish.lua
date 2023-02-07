---@mod firvish.nvim Introduction
---@brief [[
---
---Firvish is primarily a job control library.
---Additionally, it provides mechanisms which promote buffer-centric
---semantics as a means of working with job output.
---
---Practically speaking, you use firvish like so:
---1. You run a command via `firvish.start_job` and redirect its
---   output to a dedicated buffer.
---2. This dedicated buffer might have key mappings which are specific to
---   to the type of command you ran in (1). See |firvish-example-git|.
---3. You may choose to associate this job with a user command via
---   `firvish.create_user_command`. Notably, this api is designed to
---   make it easy to add |command-completion|.
---   NOTE: That this functionality is currently a work-in-progress and
---   not available on this branch.
---
---@brief ]]

local jobs = require "firvish.lib.jobs"

local firvish = {}

firvish.extension = require "firvish.extension"

firvish.filetype = require "firvish.filetype"

firvish.start_job = jobs.start_job

return firvish
