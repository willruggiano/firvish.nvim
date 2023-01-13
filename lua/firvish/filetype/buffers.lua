---@mod firvish.filetype.buffers
---@brief [[
---The buffer-local library which is passed to keymaps associated with the |firvish-buffers|
---filetype.
---@brief ]]

local Buffer = require "firvish.internal.buffer"
local BufferList = require "firvish.lib.bufferlist"

local lib = {}

---@package
function lib.setup(bufnr)
    -- Setup buffer-local features
    local buffer = Buffer:new(bufnr)
    buffer:set_options {
        bufhidden = "wipe",
        buflisted = false,
        buftype = "acwrite",
        swapfile = false,
    }

    local config = require("firvish.features.buffers").config
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

    -- Display the buffer-list
    lib.refresh(config.filter, buffer)

    -- Make it so whenever we enter the buffer the buffer-list gets refreshed
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        buffer = bufnr,
        callback = function()
            lib.refresh(config.filter, buffer)
        end,
    })

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = bufnr,
        callback = function()
            local lines = buffer:get_lines()
            local current = BufferList:new(true, config.filter)
            local desired = BufferList.parse(lines)
            ---@type BufferList
            ---@diagnostic disable-next-line: assign-type-mismatch
            local bufferlist = current / desired
            for _, buf in bufferlist:iter() do
                if buf:visible() then
                    vim.cmd.close { count = vim.fn.bufwinnr(buf.bufnr) }
                end
                -- TODO: It would be nice to capture errors here and give
                -- feedback directly in the buffer list (like LSP diagnostics)
                -- e.g. trying to delete a modified buffer
                vim.cmd.bwipeout(buf.bufnr)
            end
            buffer:set_option("modified", false)
        end,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = bufnr,
        callback = function()
            lib.refresh(config.filter, buffer)
        end,
    })
end

---Refresh the buffer list
---@param filter Filter|function only show buffers that satisfy the given filter
---@param buffer? Buffer
function lib.refresh(filter, buffer)
    if buffer == nil then
        buffer = Buffer:new(vim.api.nvim_get_current_buf())
    end
    local bufferlist = BufferList:new(true, filter)
    buffer:set_lines(bufferlist:lines())
    buffer:set_option("modified", false)
end

---Open a file from the buffer list
---@param how? string how to open the buffer, e.g. `:edit`, `:split`, `:vert pedit`, etc
function lib.open_file(how)
    local buffer = lib.buffer_at_cursor()
    buffer:open(how)
end

---Get the Buffer at the current cursor position
---@return Buffer
function lib.buffer_at_cursor()
    local line = require("firvish.lib.lines").get_cursor_line()
    return lib.buffer_at_line(line)
end

---@package
---@return Buffer
function lib.buffer_at_line(line)
    local bufnr = lib.parse_line(line)
    return Buffer:new(bufnr)
end

---@package
function lib.parse_line(line)
    local match = string.match(line, "%[(%d+)%]")
    if match ~= nil then
        return tonumber(match)
    else
        error("[firvish] Failed to get buffer from '" .. line .. "'")
    end
end

return lib
