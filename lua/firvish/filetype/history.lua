---@mod firvish.filetype.history
---@brief [[
---The buffer-local library which is passed to keymaps associated with the history list buffer,
---which itself is of |firvish-dir| filetype.
---@brief ]]

local Buffer = require "firvish.internal.buffer"
local History = require "firvish.lib.history"

local lib = {}

---@package
function lib.setup(bufnr)
    -- Setup buffer-local features
    local buffer = Buffer:new(bufnr)
    buffer:set_options {
        bufhidden = "wipe",
        buflisted = false,
        -- TODO: acwrite, make the history buffer just a normal buffer
        buftype = "nofile",
        swapfile = false,
    }

    local config = require("firvish.features.history").config
    local default_opts = { buffer = bufnr, noremap = true, silent = true }
    for mode, mappings in pairs(config.keymaps) do
        for lhs, opts in pairs(mappings) do
            if opts then
                vim.keymap.set(mode, lhs, function()
                    opts.callback(lib)
                end, vim.tbl_extend("force", default_opts, opts))
            end
        end
    end

    -- Display the history list
    lib.refresh(config.filter, buffer)

    -- Make it so whenever we enter the buffer the history-list gets refreshed
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        buffer = bufnr,
        callback = function()
            lib.refresh(config.filter, buffer)
        end,
    })
end

---Refresh the history list
---@param filter Filter|function
---@param buffer? Buffer
function lib.refresh(filter, buffer)
    if buffer == nil then
        buffer = Buffer:new(vim.api.nvim_get_current_buf())
    end
    local history = History:new(filter)
    buffer:set_lines(history:lines())
    buffer:set_option("modified", false)
end

return lib
