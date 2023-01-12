---@mod firvish.find Find
---@brief [[
---The "find" feature provides several commands that allow you to find files and populate a dedicate
---buffer with the search results. The output buffer will have its filetype set to |firvish-dir|.
---
---This command requires `fd` (https://github.com/sharkdp/fd) to be installed.
---@brief ]]
---@see firvish-dir

---@tag :Fd
---@brief [[
---:[range]Fd[!] {args}
---    Runs a find (using fd) and sends the output to a buffer.
---    If bang ! is given, the command will run in the background.
---@brief ]]

---@tag :Cfd
---@brief [[
---:[range]Cfd[!] {args}
---    Runs a find (using fd) and sends the output to the |quickfix-window|.
---    If bang ! is given, will |:copen| the quickfix-window as soon as the job completes.
---@brief ]]

---@tag :Lfd
---@brief [[
---:[range]Lfd[!] {args}
---    Runs a find (using fd) and sends the output to the |location-list-window|.
---    If bang ! is given, will |:lopen| the location-list-window as soon as the job completes.
---@brief ]]

local jobctrl = require "firvish.lib.jobs"

local find = {}

local function fd(job_opts)
    local args = vim.list_extend({ "--color=never" }, job_opts.args)

    jobctrl.start_job(vim.tbl_deep_extend("keep", {
        command = "fd",
        args = args,
        efm = "%f",
        filetype = "firvish-dir",
        title = "fd",
    }, job_opts))
end

---@package
function find.setup()
    if vim.fn.executable "fd" == 1 then
        vim.api.nvim_create_user_command("Fd", function(args)
            fd {
                args = args.fargs,
                errorlist = false,
                bopen = not args.bang,
            }
        end, { bang = true, complete = "file", nargs = "*" })

        vim.api.nvim_create_user_command("Cfd", function(args)
            fd {
                args = args.fargs,
                errorlist = "quickfix",
                eopen = args.bang,
                bopen = false,
            }
        end, { bang = true, complete = "file", nargs = "*" })

        vim.api.nvim_create_user_command("Lfd", function(args)
            fd {
                args = args.fargs,
                errorlist = "loclist",
                eopen = args.bang,
                bopen = false,
            }
        end, { bang = true, complete = "file", nargs = "*" })
    end
end

return find
