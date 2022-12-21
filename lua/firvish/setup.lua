local keymap = require "firvish.keymap"
local jobs = require "firvish.job_control"

local opts = require("firvish.config").config

vim.filetype.add {
    filename = {
        ["firvish-buffers"] = function(_, bufnr)
            require("firvish.buffers").setup(bufnr)
            return "firvish-buffers"
        end,
        ["firvish-history"] = function(_, bufnr)
            require("firvish.history").setup(bufnr)
            return "firvish-history"
        end,
        ["firvish-menu"] = function(_, bufnr)
            require("firvish.menu").setup(bufnr)
            return "firvish-menu"
        end,
    },
}

if opts.use_default_mappings then
    keymap.nnoremap("<leader>b", require("firvish.buffers").open_buffers)
    keymap.nnoremap("<leader>h", require("firvish.history").open_history)
end

if opts.create_user_commands then
    vim.api.nvim_create_user_command("Buffers", require("firvish.buffers").open_buffers, {})
    vim.api.nvim_create_user_command("History", require("firvish.history").open_history, {})

    if vim.fn.executable "rg" == 1 then
        local function rg(args, use_last_buffer, qf, loc, open)
            local command = {
                "rg",
                "--column",
                "--line-number",
                "--no-heading",
                "--vimgrep",
                "--color=never",
                "--smart-case",
                "--block-buffered",
            }
            if args then
                command = vim.list_extend(command, args)
            end

            jobs.start_job {
                cmd = command,
                filetype = "firvish-dir",
                title = "rg",
                use_last_buffer = use_last_buffer,
                listed = true,
                efm = { "%f:%l:%c:%m" },
                output_qf = qf,
                open_qf = open,
                output_lqf = loc,
                open_lqf = open,
                is_background_job = qf or loc,
            }
        end

        vim.api.nvim_create_user_command("Rg", function(args)
            rg(args.fargs, args.bang, false, false, false)
        end, { bang = true, nargs = "*", complete = "file" })

        vim.api.nvim_create_user_command("Crg", function(args)
            rg(args.fargs, false, true, false, args.bang)
        end, { bang = true, nargs = "*", complete = "file" })

        vim.api.nvim_create_user_command("Lrg", function(args)
            rg(args.fargs, false, false, true, args.bang)
        end, { bang = true, nargs = "*", complete = "file" })
    end

    if vim.fn.executable "ugrep" == 1 then
        local function ug(args, use_last_buffer, qf, loc)
            local command = {
                "ugrep",
                "--column-number",
                "--line-number",
                "--color=never",
                "--smart-case",
                "--line-buffered",
                "-J1",
            }
            if args then
                command = vim.list_extend(command, args)
            end

            jobs.start_job {
                cmd = command,
                filetype = "firvish-dir",
                title = "ugrep",
                use_last_buffer = use_last_buffer,
                listed = true,
                output_qf = qf,
                efm = { "%f:%l:%c:%m" },
                output_lqf = loc,
                is_background_job = qf or loc,
            }
        end

        vim.api.nvim_create_user_command("Ug", function(args)
            ug(args.fargs, args.bang, false, false)
        end, { bang = true, complete = "file", nargs = "*" })

        vim.api.nvim_create_user_command("Cug", function(args)
            ug(args.fargs, false, false, false)
        end, { complete = "file", nargs = "*" })

        vim.api.nvim_create_user_command("Lug", function(args)
            ug(args.fargs, false, false, true)
        end, { complete = "file", nargs = "*" })
    end

    if vim.fn.executable "fd" == 1 then
        local function fd(args, use_last_buffer, qf, loc, open)
            local command = { "fd", "--color=never" }
            if args then
                command = vim.list_extend(command, args)
            end

            jobs.start_job {
                cmd = command,
                filetype = "firvish-dir",
                title = "fd",
                use_last_buffer = use_last_buffer,
                listed = true,
                efm = { "%f" },
                output_qf = qf,
                open_qf = open,
                output_lqf = loc,
                open_lqf = open,
                is_background_job = qf or loc,
            }
        end

        vim.api.nvim_create_user_command("Fd", function(args)
            fd(args.fargs, args.bang, false, false, false)
        end, { bang = true, complete = "file", nargs = "*" })

        vim.api.nvim_create_user_command("Cfd", function(args)
            fd(args.fargs, false, true, false, args.bang)
        end, { bang = true, complete = "file", nargs = "*" })

        vim.api.nvim_create_user_command("Lfd", function(args)
            fd(args.fargs, false, false, true, args.bang)
        end, { bang = true, complete = "file", nargs = "*" })
    end

    local function frun(args, is_background_job, qf, loc)
        jobs.start_job {
            cmd = args,
            filetype = "firvish-job",
            title = "job",
            use_last_buffer = false,
            listed = true,
            output_qf = qf,
            output_lqf = loc,
            is_background_job = qf or loc or is_background_job,
        }
    end

    vim.api.nvim_create_user_command("FRun", function(args)
        frun(args.fargs, args.bang, false, false)
    end, { bang = true, complete = "file", nargs = "*" })

    vim.api.nvim_create_user_command("Cfrun", function(args)
        frun(args.fargs, false, true, false)
    end, { complete = "file", nargs = "*" })

    vim.api.nvim_create_user_command("Lfrun", function(args)
        frun(args.fargs, false, false, true)
    end, { complete = "file", nargs = "*" })

    vim.api.nvim_create_user_command("Fhdo", function(args)
        require("firvish").open_linedo_buffer(args.line1, args.line2, vim.fn.bufnr(), args.fargs, args.bang == false)
    end, { complete = "file", nargs = "*" })

    vim.api.nvim_create_user_command("FirvishJobs", require("firvish.job_control").show_jobs_list, { bar = true })

    vim.api.nvim_create_user_command("Fhfilter", function(args)
        require("firvish").filter_lines(args.line1, args.line2, args.bang == false, args.fargs)
    end, { bang = true, nargs = "*", range = true })

    vim.api.nvim_create_user_command("Fhqf", function(args)
        require("firvish").set_buf_lines_to_qf(args.line1, args.line2, args.bang, false)
    end, { bang = true, range = true })

    vim.api.nvim_create_user_command("Fhll", function(args)
        require("firvish").set_buf_lines_to_qf(args.line1, args.line2, args.bang, true)
    end, { bang = true, range = true })

    local augroup = vim.api.nvim_create_augroup("firvish-buffers", { clear = true })
    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufAdd" }, {
        callback = require("firvish.buffers").mark_dirty,
        group = augroup,
    })
end
