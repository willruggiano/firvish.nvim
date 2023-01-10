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
---            keymaps = {
---                n = {
---                    ["<enter>"] = {
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

buffers.config = {
    open = "edit",
    bang_open = "vsplit",
    keymaps = {
        n = {
            ["<enter>"] = {
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

---@package
function buffers.setup(opts)
    buffers.config = vim.tbl_deep_extend("force", buffers.config, opts or {})

    vim.api.nvim_create_user_command("Buffers", function(args)
        ---@diagnostic disable-next-line: redundant-parameter
        require("firvish.buffers").open_buffer_list(args.bang and buffers.config.bang_open or buffers.config.open)
    end, { bang = true })

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
        pattern = "firvish-buffers",
        callback = function(args)
            require("firvish.buffers").on_filetype(args)
        end,
    })
end

---@package
---@param buffer Buffer
function buffers.setup_buffer_list_buffer(buffer)
    buffer:apply_keymaps(buffers.config.keymaps)
end

return buffers
