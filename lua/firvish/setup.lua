local keymap = require "firvish.keymap"
local jobs = require "firvish.job_control"

local opts = require("firvish.config").config

vim.filetype.add {
    filename = {
        ["firvish-buffers"] = "firvish-buffers",
        ["firvish-history"] = "firvish-history",
        ["firvish-jobs"] = "firvish-jobs",
        ["firvish-menu"] = "firvish-menu",
    },
}

if opts.use_default_mappings then
    keymap.nnoremap("<leader>b", require("firvish.buffers").open_buffers)
    keymap.nnoremap("<leader>h", require("firvish.history").open_history)
end

if opts.create_user_commands then
    vim.api.nvim_create_user_command("Buffers", require("firvish.buffers").open_buffer_list, {})
    vim.api.nvim_create_user_command("History", require("firvish.history").open_history, {})

    if vim.fn.executable "rg" == 1 then
        local function rg(job_opts)
            local args = vim.list_extend({ "--color=never", "--vimgrep" }, job_opts.args)

            require("firvish.job_control2").start_job(vim.tbl_deep_extend("keep", {
                command = "rg",
                args = args,
                filetype = "firvish-dir",
                title = "rg",
            }, job_opts))
        end

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

    if vim.fn.executable "fd" == 1 then
        local function fd(job_opts)
            local args = vim.list_extend({ "--color=never" }, job_opts.args)

            require("firvish.job_control2").start_job(vim.tbl_deep_extend("keep", {
                command = "fd",
                args = args,
                efm = "%f",
                filetype = "firvish-dir",
                title = "fd",
            }, job_opts))
        end

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

    local function frun(fargs, job_opts)
        require("firvish.job_control2").start_job(vim.tbl_deep_extend("keep", {
            command = fargs[1],
            args = vim.list_slice(fargs, 2, #fargs),
            filetype = "firvish-job",
            title = "job",
        }, job_opts))
    end

    -- :Frun[!] <args>
    -- Runs a command and sends the output to a buffer.
    -- <bang> causes the command to run in the background.
    vim.api.nvim_create_user_command("Frun", function(args)
        frun(args.fargs, {
            errorlist = false,
            bopen = not args.bang,
        })
    end, { bang = true, complete = "file", nargs = "*" })

    -- :Cfrun[!] <args>
    -- Runs a command and sends the command output to a quickfix list.
    -- <bang> causes the quickfix list to be opened as soon as the Job completes.
    vim.api.nvim_create_user_command("Cfrun", function(args)
        frun(args.fargs, {
            errorlist = "quickfix",
            eopen = args.bang,
            bopen = false,
        })
    end, { bang = true, nargs = "*" })

    -- :Lfrun[!] <args>
    -- Runs a command and sends the command output to a location list.
    -- <bang> causes the location list to be opened as soon as the Job completes.
    vim.api.nvim_create_user_command("Lfrun", function(args)
        frun {
            errorlist = "loclist",
            eopen = args.bang,
            bopen = false,
        }
    end, { bang = true, nargs = "*" })

    vim.api.nvim_create_user_command("Fhdo", function(args)
        require("firvish").open_linedo_buffer(args.line1, args.line2, vim.fn.bufnr(), args.args, args.bang == false)
    end, { complete = "file", nargs = "*" })

    vim.api.nvim_create_user_command("FirvishJobs", require("firvish.job_control2").open, { bar = true })

    vim.api.nvim_create_user_command("Fhfilter", function(args)
        require("firvish").filter_lines(args.line1, args.line2, args.bang == false, args.args)
    end, { bang = true, bar = true, nargs = "*", range = true })

    vim.api.nvim_create_user_command("Fhqf", function(args)
        require("firvish").send_buf_lines_to_qf(args.line1 - 1, args.line2, args.bang, "quickfix")
    end, { bang = true, bar = true, range = true })

    vim.api.nvim_create_user_command("Fhll", function(args)
        require("firvish").send_buf_lines_to_qf(args.line1 - 1, args.line2, args.bang, "loclist")
    end, { bang = true, bar = true, range = true })
end

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    callback = function(args)
        require("firvish.buffers").on_buf_delete(args)
    end,
})

vim.api.nvim_create_autocmd("BufAdd", {
    callback = function(args)
        require("firvish.buffers").on_buf_add(args)
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        require("firvish.buffers").on_filetype(args)
    end,
})
