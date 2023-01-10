---@mod firvish.frun Frun
---@tag :Frun
---@tag :Cfrun
---@tag :Lfrun
---@brief [[
---Frun stuff
---@brief ]]

local jobctrl = require "firvish.jobs"

local frun = {}

local function frun_(fargs, job_opts)
    jobctrl.start_job(vim.tbl_deep_extend("keep", {
        command = fargs[1],
        args = vim.list_slice(fargs, 2, #fargs),
        filetype = "firvish-job",
        title = "job",
    }, job_opts))
end

---@package
function frun.setup()
    -- :Frun[!] <args>
    -- Runs a command and sends the output to a buffer.
    -- <bang> causes the command to run in the background.
    vim.api.nvim_create_user_command("Frun", function(args)
        frun_(args.fargs, {
            errorlist = false,
            bopen = not args.bang,
        })
    end, { bang = true, complete = "file", nargs = "*" })

    -- :Cfrun[!] <args>
    -- Runs a command and sends the command output to a quickfix list.
    -- <bang> causes the quickfix list to be opened as soon as the Job completes.
    vim.api.nvim_create_user_command("Cfrun", function(args)
        frun_(args.fargs, {
            errorlist = "quickfix",
            eopen = args.bang,
            bopen = false,
        })
    end, { bang = true, nargs = "*" })

    -- :Lfrun[!] <args>
    -- Runs a command and sends the command output to a location list.
    -- <bang> causes the location list to be opened as soon as the Job completes.
    vim.api.nvim_create_user_command("Lfrun", function(args)
        frun_(args.fargs, {
            errorlist = "loclist",
            eopen = args.bang,
            bopen = false,
        })
    end, { bang = true, nargs = "*" })
end

return frun
