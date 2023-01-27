---@mod cmake CMake
---@brief [[
---Creates a :CMake user command which can be used to run arbitrary cmake commands.
---After calling `setup()`, you can then:
---  * Generate a buildsystem: `:CMake -S . -B build -DCMAKE_BUILD_TYPE=Release`
---  * Build a project or target: `:CMake --build build --target my_exe --parallel 8`
---
---Invoking the command with bang ! will run the command in the background and
---open a quickfix list with the output once the command completes.
---
--->
---:CMake! --build build --target my_exe --parallel 8
---<
---@brief ]]

local cmake = {}

local jobs = require "firvish.lib.jobs"

function cmake.setup(opts)
  opts = opts or {}
  vim.api.nvim_create_user_command("CMake", function(args)
    jobs.start_job {
      command = opts.exe or "cmake",
      args = args.fargs,
      filetype = "log",
      title = "cmake",
      errorlist = args.bang and "quickfix",
      eopen = args.bang == true,
      bopen = args.bang == false,
    }
  end, { bang = true, nargs = "*" })
end

return cmake
