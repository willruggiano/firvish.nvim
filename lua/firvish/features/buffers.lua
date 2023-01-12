---@mod firvish.features.buffers Buffers
---@brief [[
---The buffer list is like |:ls| except that the buffer list itself is contained in a normal vim
---buffer. This allows you to manipulate it like any other buffer. You can |dd| a few lines
---and |:write| the buffer to delete buffers (|:bdelete|, |:bwipeout|). You can edit buffer names by
---editing the line corresponding to that buffer.
---
---The buffer list can be configured through |firvish.setup|. By default, it has the following
---configuration:
---
--->
---require("firvish").setup {
---    features = {
---        buffers = {
---            behavior = {
---                -- Specifies how to open the buffer list when using the |:Buffers| command
---                -- or the Lua API.
---                open = "edit",
---                -- Specifies how to open the buffer list when bang ! is given to the |:Buffers|
---                -- command.
---                bang_open = "vsplit",
---            },
---            -- The default filter applied to the buffer list. Only show buffers that are listed
---            -- and not a quickfix or firvish buffer.
---            -- See |firvish-filters|
---            filter = buf_listed + (buf_buftype_not { "quickfix" }) + (buf_filetype_not { "firvish-*" }),
---            keymaps = {
---                -- See |firvish-buffers-keymaps|
---            },
---        },
---    },
---}
---<
---@brief ]]
---@see firvish-buffers
---@see firvish-buffer-api

---@tag :Buffers
---@brief [[
---:Buffers[!]
---    Opens the buffer list.
---    If bang ! is given, will use the alternate open behavior:
---    `features.buffers.behavior.bang_open`
---
---@brief ]]

---@tag firvish-buffers
---@tag firvish-buffers-keymaps
---@brief [[
---The firvish-buffers filetype is used when viewing the buffer list.
---
---Default mappings ~
---    <CR>    Open file under cursor
---    <C-s>   Open file under cursor in a split
---    <C-v>   Open file under cursor in a vertical split
---
---Mappings can be configured through |firvish.setup|. Assigning a mapping to `false` disables it.
---When configuring mappings through |firvish.setup|, you must specify a callback function. This
---callback function will receive the buffer-local lib (|firvish.filetype.buffers|) which can be used to
---perform common actions relevant to the buffer list (getting the buffer under the cursor,
---refreshing the buffer list, etc).
---
--->
---require("firvish").setup {
---    features = {
---        buffers = {
---            keymaps = {
---                n = {
---                    gm = {
---                        callback = function(lib)
---                            -- Filter the buffer list to show only modified files
---                            local is_modified = Filter:new(function(buffer)
---                                return buffer:get_option "modified" == true
---                            end)
---                            lib.refresh(is_modified)
---                        end,
---                        desc = "[firvish] Filter modified files",
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
    ---@type Filter
    ---@diagnostic disable-next-line: assign-type-mismatch
    filter = filters.buf_listed - filters.buf_buftype(default_excluded_buftypes) - filters.buf_filetype(
        default_excluded_filetypes
    ),
    keymaps = {
        n = {
            ["<CR>"] = {
                callback = function(lib)
                    lib.open_file "edit"
                end,
                desc = "[firvish] Open buffer under cursor",
            },
            ["<C-s>"] = {
                callback = function(lib)
                    lib.open_file "split"
                end,
                desc = "[firvish] :split buffer under cursor",
            },
            ["<C-v>"] = {
                callback = function(lib)
                    lib.open_file "vsplit"
                end,
                desc = "[firvish] :vsplit buffer under cursor",
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
            [filename] = "firvish-buffers",
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
