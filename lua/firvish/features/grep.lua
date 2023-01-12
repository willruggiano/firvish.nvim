---@mod firvish.grep Grep
---@tag :Rg
---@tag :Crg
---@tag :Lrg
---@brief [[
---Ripgrep stuff.
---@brief ]]

local jobctrl = require "firvish.lib.jobs"

local grep = {}

local function rg(job_opts)
    local args = vim.list_extend({ "--color=never", "--vimgrep" }, job_opts.args)

    jobctrl.start_job(vim.tbl_deep_extend("keep", {
        command = "rg",
        args = args,
        filetype = "firvish-dir",
        title = "rg",
    }, job_opts))
end

---@package
function grep.setup()
    if vim.fn.executable "rg" == 1 then
        -- :Rg[!] <args>
        -- Runs a grep (using ripgrep) and sends the output to a buffer.
        -- <bang> causes the grep to be run in the background
        vim.api.nvim_create_user_command("Rg", function(args)
            rg {
                args = args.fargs,
                errorlist = false,
                bopen = not args.bang,
            }
        end, { bang = true, nargs = "*", complete = "file" })

        -- :Crg[!] <args>
        -- Runs a grep (using ripgrep) and outputs the matches to a quickfix list.
        -- <bang> causes the quickfix list to be opened as soon as the Job completes
        vim.api.nvim_create_user_command("Crg", function(args)
            rg {
                args = args.fargs,
                errorlist = "quickfix",
                eopen = args.bang,
                bopen = false,
            }
        end, { bang = true, nargs = "*", complete = "file" })

        -- :Lrg[!] <args>
        -- Runs a grep (using ripgrep) and outputs the matches to a location list.
        -- <bang> causes the location list to be opened as soon as the Job completes
        vim.api.nvim_create_user_command("Lrg", function(args)
            rg {
                args = args.fargs,
                errorlist = "loclist",
                eopen = args.bang,
                bopen = false,
            }
        end, { bang = true, nargs = "*", complete = "file" })
    end
end

return grep
