---@mod ls-files LsFiles
---@brief [[
---Creates a :LsFiles user command which can be used to open a buffer with the
---output of `git ls-files`.
---
---Invoking the command with bang ! will instruct git to only list modified files.
---
--->
---:LsFiles! lua/firvish/lib
---<
---@brief ]]

local git = {}

local jobs = require "firvish.lib.jobs"

function git.ls(only_modified, files)
  local args = { "ls-files" }
  if only_modified then
    table.insert(args, "-m")
  end
  jobs.start_job {
    command = "git",
    args = vim.list_extend(args, files),
    filetype = "firvish-dir",
    title = "git ls-files",
    bopen = {
      headers = false,
    },
  }
end

function git.setup()
  vim.api.nvim_create_user_command("LsFiles", function(args)
    git.ls(args.bang, args.fargs)
  end, {
    bang = true,
    nargs = "*",
    desc = "List git files",
  })
end

git.setup()

return git
