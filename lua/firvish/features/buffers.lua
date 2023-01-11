---@mod firvish.features.buffers :Buffers
---@tag :Buffers
---@brief [[
---The `:Buffers` command opens the buffer list.
---
---How the `:Buffers` command opens the buffer list can be customized through |firvish.setup|:
---
--->
---require("firvish").setup {
---  features = {
---    buffers = {
---      open = "edit",        -- Corresponds to |:edit|
---      bang_open = "vsplit", -- Corresponds to |:vsplit|
---    },
---  },
---}
---<
---
---@brief ]]

---@tag firvish-buffers
---@brief [[
---The buffer list comes with some default keymaps.
---You can add your own keymaps or change the default keymaps by including
---them when calling |firvish.setup|. To disable a keymap, map it to `false`.
---
--->
---require("firvish").setup {
---    features = {
---        buffers = {
---            behavior = {
---                open = "edit",
---                bang_open = "vsplit",
---            },
---            filter = buf_listed + (buf_buftype_not { "quickfix" }) + (buf_filetype_not { "firvish-buffers" }),
---            keymaps = {
---                n = {
---                    ["<CR>"] = {
---                        function()
---                            require("firvish.buffers").jump_to_buffer()
---                        end,
---                        { desc = "[firvish] Jump to buffer" },
---                    },
---                    ["-"] = {
---                        function()
---                            vim.cmd "edit firvish-menu"
---                        end,
---                        { desc = "[firvish] Menu" },
---                    },
---                    ["za"] = {
---                        function()
---                            require("firvish.buffers").filter_buffers "args"
---                        end,
---                        { desc = "[firvish] Filter buffers (argv)" },
---                    },
---                    ["zm"] = {
---                        function()
---                            require("firvish.buffers").filter_buffers "modified"
---                        end,
---                        { desc = "[firvish] Filter buffers (modified)" },
---                    },
---                    ["zv"] = {
---                        function()
---                            require("firvish.buffers").filter_buffers "current_tab"
---                        end,
---                        { desc = "[firvish] Filter buffers (visible)" },
---                    },
---                    ["R"] = {
---                        function()
---                            require("firvish.buffers").rename_buffer()
---                        end,
---                        { desc = "[firvish] Rename buffer" },
---                    },
---                },
---            },
---        },
---    },
---}
---<
---
---@brief ]]

local buffers = {}

local default_excluded_filetypes = { "firvish-buffers", "firvish-dir", "firvish-jobs" }
local default_excluded_buftypes = { "quickfix" }
local filters = require "firvish.lib.filters.buffer"

buffers.config = {
    behavior = {
        open = "edit",
        bang_open = "vsplit",
    },
    filter = filters.buf_listed - filters.buf_buftype(default_excluded_buftypes) - filters.buf_filetype(
        default_excluded_filetypes
    ),
    keymaps = {
        n = {
            ["<CR>"] = {
                function()
                    require("firvish.buffers").jump_to_buffer()
                end,
                { desc = "[firvish] Jump to buffer" },
            },
            ["-"] = {
                function()
                    vim.cmd "edit firvish-menu"
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
}

local filename = "firvish://buffers"

---@package
function buffers.setup(opts)
    buffers.config = vim.tbl_deep_extend("force", buffers.config, opts or {})

    vim.filetype.add {
        filename = {
            ["firvish://buffers"] = "firvish-buffers",
        },
    }

    vim.api.nvim_create_user_command("Buffers", function(args)
        if args.bang then
            vim.cmd(buffers.config.behavior.bang_open .. " " .. filename)
        else
            vim.cmd(buffers.config.behavior.open .. " " .. filename)
        end
    end, { bang = true })
end

return buffers
