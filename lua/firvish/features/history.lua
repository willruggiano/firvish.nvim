---@mod firvish.features.history History
---@brief [[
---The history list is like |:oldfiles| execept that the list of files is contained in a normal vim
---buffer. This allows you to manipulate it like any other buffer. TODO: For example...
---
---The history list can be configured through |firvish.setup|. By default, it has the following
---configuration:
---
--->
---
---<
---
---@brief ]]
---@see firvish-dir

---@tag :History
---@brief [[
---:History[!]
---    Opens the history list.
---    If bang ! is given, will use the alternate open behavior:
---    `features.history.behavior.bang_open`
---
---@brief ]]

---@tag firvish-history-keymaps
---@brief [[
---In addition to the normal |firvish-dir| mappings, the history list also has a few others:
---
---Default mappings (in addition to |firvish-dir| mappings) ~
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
---        history = {
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

local history = {}

history.config = {
    behavior = {
        open = "edit",
        bang_open = "vsplit",
    },
    keymaps = {
        n = {
            --
        },
    },
}

local filename = "firvish://history"

---@package
function history.setup(opts)
    history.config = vim.tbl_deep_extend("force", history.config, opts or {})

    vim.filetype.add {
        filename = {
            [filename] = function(_, bufnr)
                require("firvish.filetype.history").setup(bufnr)
                return "firvish-dir"
            end
        },
    }

    vim.api.nvim_create_user_command("History", function(args)
        if args.bang then
            vim.cmd(history.config.behavior.bang_open .. " " .. filename)
        else
            vim.cmd(history.config.behavior.open .. " " .. filename)
        end
    end, { bang = true })
end

return history
