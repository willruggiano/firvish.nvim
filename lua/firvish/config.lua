local M = {}

local preview_mappings = {
    n = {
        ["<enter>"] = {
            function()
                require("firvish").open_file_under_cursor("", false, true, false)
            end,
            { desc = "Open file under cursor" },
        },
        ["P"] = {
            function()
                require("firvish").open_file_under_cursor("", true, true, true)
            end,
            { desc = "Open file under cursor" },
        },
        ["a"] = {
            function()
                require("firvish").open_file_under_cursor("", true, false, true)
            end,
            { desc = "Open file under cursor" },
        },
        ["o"] = {
            function()
                require("firvish").open_file_under_cursor("", true, false, false)
            end,
            { desc = "Open file under cursor" },
        },
        ["<C-N>"] = {
            function()
                require("firvish").open_file_under_cursor("down", true, true, true)
            end,
            { desc = "Open file under cursor" },
        },
        ["<C-P>"] = {
            function()
                require("firvish").open_file_under_cursor("up", true, true, true)
            end,
            { desc = "Open file under cursor" },
        },
    },
}

M.config = {
    ignore_buffers = {
        buftype = { "quickfix" },
    },
    interactive_window_height = 3,
    shell = vim.opt.shell:get(),
    keymaps = {
        buffers = {
            n = {
                ["<enter>"] = {
                    function()
                        require("firvish.buffers").jump_to_buffer()
                    end,
                    { desc = "[firvish] Jump to buffer" },
                },
                ["-"] = {
                    function()
                        vim.cmd "edit firvish://menu"
                    end,
                    { desc = "[firvish] Menu" },
                },
                ["za"] = {
                    function()
                        require("firvish.buffers").filter_buffers "args"
                    end,
                    { desc = "[firvish] Filter buffers (argv)" },
                },
                ["zm"] = {
                    function()
                        require("firvish.buffers").filter_buffers "modified"
                    end,
                    { desc = "[firvish] Filter buffers (modified)" },
                },
                ["zv"] = {
                    function()
                        require("firvish.buffers").filter_buffers "current_tab"
                    end,
                    { desc = "[firvish] Filter buffers (visible)" },
                },
                ["R"] = {
                    function()
                        require("firvish.buffers").rename_buffer()
                    end,
                    { desc = "[firvish] Rename buffer" },
                },
            },
        },
        dir = preview_mappings,
        history = {
            n = {
                ["<enter>"] = {
                    function()
                        require("firvish.history").open_file()
                    end,
                    { desc = "[firvish] Open file" },
                },
                ["gq"] = {
                    function()
                        require("firvish.history").close_history()
                    end,
                    { desc = "[firvish] Close" },
                },
                ["R"] = {
                    function()
                        require("firvish.history").refresh_history()
                    end,
                    { desc = "[firvish] Refresh" },
                },
                ["-"] = {
                    function()
                        vim.cmd "edit firvish://menu"
                    end,
                    { desc = "[firvish] Menu" },
                },
            },
        },
        ["job"] = preview_mappings,
        ["jobs"] = {
            n = {
                ["<enter>"] = {
                    function()
                        local line = vim.fn.line "."
                        local lines = vim.api.nvim_buf_get_var(0, "firvish_job_list_additional_lines")
                        require("firvish.job_control").preview_job_output(lines[line].job_id)
                    end,
                    { desc = "[firvish] Preview job output" },
                },
                ["dd"] = {
                    ---@param job_list_buffer JobListBuffer
                    function(job_list_buffer)
                        job_list_buffer:remove_job_at(vim.fn.line ".", true)
                    end,
                    { desc = "[firvish] Delete job" },
                },
                ["E"] = {
                    function()
                        local line = vim.fn.line "."
                        local lines = vim.b.firvish_job_list_additional_lines
                        require("firvish.job_control").echo_job_output(
                            lines[line].job_id,
                            math.max(vim.v.count, 1) * -1
                        )
                    end,
                    { desc = "[firvish] Echo job output" },
                },
                ["P"] = {
                    function()
                        local line = vim.fn.line "."
                        local lines = vim.api.nvim_buf_get_var(0, "firvish_job_list_additional_lines")
                        require("firvish.job_control").preview_job_output(lines[line].job_id)
                    end,
                    { desc = "[firvish] Preview job output" },
                },
                ["R"] = {
                    function()
                        require("firvish.job_control").refresh_job_list_window()
                    end,
                    { desc = "[firvish] Refresh" },
                },
                ["S"] = {
                    function()
                        require("firvish.job_control").stop_job()
                    end,
                    { desc = "[firvish] Stop job" },
                },
            },
        },
        ["job-output"] = {
            n = {
                ["gb"] = {
                    function()
                        require("firvish.job_control").go_back_from_job_output()
                    end,
                    { desc = "[firvish] Go back to job list" },
                },
            },
        },
        menu = {
            n = {
                ["<enter>"] = {
                    function()
                        require("firvish.menu").open_item(vim.fn.line ".")
                    end,
                    { desc = "[firvish] Open item" },
                },
                ["R"] = {
                    function()
                        require("firvish.menu").refresh_menu()
                    end,
                    { desc = "[firvish] Refresh" },
                },
            },
        },
    },
}

local default_opts = { noremap = true, silent = true }

---@param buffer Buffer
M.apply_mappings = function(key, buffer)
    local config = M.config
    for mode, mappings in pairs(config.keymaps[key]) do
        for lhs, map in pairs(mappings or {}) do
            if map then
                local rhs = type(map) == "table" and map[1] or map
                local opts = type(map) == "table" and map[2] or {}
                buffer:set_keymap(mode, lhs, rhs, vim.tbl_deep_extend("force", default_opts, opts or {}))
            end
        end
    end
end

M.merge = function(opts)
    local config = M.config
    M.config = vim.tbl_deep_extend("force", config, opts)
    return config
end

return M
