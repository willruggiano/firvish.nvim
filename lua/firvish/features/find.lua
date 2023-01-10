---@mod firvish.find Find

local jobctrl = require "firvish.jobs"

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
        -- :Fd[!] <args>
        -- Runs a find (using fd) and sends the output to a buffer.
        -- <bang> causes the find to be run in the background
        vim.api.nvim_create_user_command("Fd", function(args)
            fd {
                args = args.fargs,
                errorlist = false,
                bopen = not args.bang,
            }
        end, { bang = true, complete = "file", nargs = "*" })

        -- :Cfd[!] <args>
        -- Runs a find (using fd) and outputs the matches to a quickfix list.
        -- <bang> causes the quickfix list to be opened as soon as the Job completes
        vim.api.nvim_create_user_command("Cfd", function(args)
            fd {
                args = args.fargs,
                errorlist = "quickfix",
                eopen = args.bang,
                bopen = false,
            }
        end, { bang = true, complete = "file", nargs = "*" })

        -- :Lfd[!] <args>
        -- Runs a find (using fd) and outputs the matches to a location list.
        -- <bang> causes the location list to be opened as soon as the Job completes
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
