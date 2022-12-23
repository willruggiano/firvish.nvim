local M = {}

local preview_mappings = {
    n = {
        ["<enter>"] = function()
            require("firvish").open_file_under_cursor("", false, true, false)
        end,
        ["P"] = function()
            require("firvish").open_file_under_cursor("", true, true, true)
        end,
        ["a"] = function()
            require("firvish").open_file_under_cursor("", true, false, true)
        end,
        ["o"] = function()
            require("firvish").open_file_under_cursor("", true, false, false)
        end,
        ["<C-N>"] = function()
            require("firvish").open_file_under_cursor("down", true, true, true)
        end,
        ["<C-P>"] = function()
            require("firvish").open_file_under_cursor("up", true, true, true)
        end,
    },
}

M.config = {
    interactive_window_height = 3,
    shell = vim.opt.shell:get(),
    keymaps = {
        buffers = {
            n = {
                ["<enter>"] = function()
                    require("firvish.buffers").jump_to_buffer()
                end,
                ["-"] = function()
                    vim.cmd "edit firvish://menu"
                end,
                ["fa"] = function()
                    require("firvish.buffers").filter_buffers "args"
                end,
                ["fm"] = function()
                    require("firvish.buffers").filter_buffers "modified"
                end,
                ["ft"] = function()
                    require("firvish.buffers").filter_buffers "current_tab"
                end,
                ["R"] = function()
                    require("firvish.buffers").rename_buffer()
                end,
            },
        },
        dir = preview_mappings,
        history = {
            n = {
                ["<enter>"] = function()
                    require("firvish.history").open_file()
                end,
                ["gq"] = function()
                    require("firvish.history").close_history()
                end,
                ["R"] = function()
                    require("firvish.history").refresh_history()
                end,
                ["-"] = function()
                    vim.cmd "edit firvish://menu"
                end,
            },
        },
        job = preview_mappings,
        ["job-list"] = {
            n = {
                ["<enter>"] = function()
                    local line = vim.fn.line "."
                    local lines = vim.api.nvim_buf_get_var(0, "firvish_job_list_additional_lines")
                    require("firvish.job_control").preview_job_output(lines[line].job_id)
                end,
                ["dd"] = function()
                    require("firvish.job_control").delete_job_from_history(false)
                end,
                ["E"] = function()
                    local line = vim.fn.line "."
                    local lines = vim.b.firvish_job_list_additional_lines
                    require("firvish.job_control").echo_job_output(lines[line].job_id, math.max(vim.v.count, 1) * -1)
                end,
                ["P"] = function()
                    local line = vim.fn.line "."
                    local lines = vim.api.nvim_buf_get_var(0, "firvish_job_list_additional_lines")
                    require("firvish.job_control").preview_job_output(lines[line].job_id)
                end,
                ["R"] = function()
                    require("firvish.job_control").refresh_job_list_window()
                end,
                ["S"] = function()
                    require("firvish.job_control").stop_job()
                end,
            },
        },
        ["job-output"] = {
            n = {
                ["gb"] = function()
                    require("firvish.job_control").go_back_from_job_output()
                end,
            },
        },
        menu = {
            n = {
                ["<enter>"] = function()
                    require("firvish.menu").open_item(vim.fn.line ".")
                end,
                ["R"] = function()
                    require("firvish.menu").refresh_menu()
                end,
            },
        },
    },
}

---@param buffer Buffer
M.apply_mappings = function(map, buffer)
    local config = M.config
    for mode, mappings in pairs(config.keymaps[map]) do
        for lhs, rhs in pairs(mappings or {}) do
            if rhs then
                buffer:set_keymap(mode, lhs, rhs, { noremap = true, nowait = true, silent = true })
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
