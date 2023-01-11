---@mod firvish.filetype.buffers firvish-buffers
---@tag firvish-buffers
---@brief [[
---The firvish-buffers filetype is used when viewing the buffer list.
---
---Mappings ~
---    <CR>    Open file under cursor
---    <C-s>   Open file under cursor is a split
---    <C-v>   Open file under cursor is a vertical split
---@brief ]]

local Buffer = require "firvish.internal.buffer"
local BufferList = require "firvish.lib.bufferlist"

local lines = require "firvish.lib.lines"

local ft = {}

---@package
function ft.setup(bufnr)
    -- Setup buffer-local features
    local config = require("firvish.features.buffers").config
    local buffer = Buffer:new(bufnr)
    buffer:set_options {
        bufhidden = "wipe",
        buflisted = false,
        buftype = "nofile",
        swapfile = false,
    }

    vim.keymap.set("n", "<CR>", function()
        ft.open_file "edit"
    end, { buffer = bufnr, desc = "[firvish] Open file under cursor", noremap = true, silent = true })

    vim.keymap.set("n", "<C-s>", function()
        ft.open_file "split"
    end, { buffer = bufnr, desc = "[firvish] :split file under cursor", noremap = true, silent = true })

    vim.keymap.set("n", "<C-v>", function()
        ft.open_file "vsplit"
    end, { buffer = bufnr, desc = "[firvish] :vsplit file under cursor", noremap = true, silent = true })

    -- Display the buffer-list
    ft.refresh(buffer, config.filter)

    -- Make it so whenever we enter the buffer the buffer-list gets refreshed
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        buffer = bufnr,
        callback = function()
            ft.refresh(buffer, config.filter)
        end,
    })
end

---@package
---@param buffer Buffer
function ft.refresh(buffer, filter)
    local bufferlist = BufferList:new(true, filter)
    buffer:set_lines(bufferlist:lines())
    -- TODO: Make the buffer list buffer "just a normal buffer".
    -- Meaning, I could `d3d` a few lines (which correspond to buffers)
    -- and, upon writing the buffer list buffer, those buffers would get `:bdeleted`.
    -- Not quite sure how to do that right now though, something about acwrite and BufWriteCmd.
    buffer:set_option("modified", false)
end

---@package
function ft.open_file(how)
    local buffer = ft.buffer_at_cursor()
    buffer:open(how)
end

---@package
function ft.buffer_at_cursor()
    local line = lines.get_cursor_line()
    return ft.buffer_at_line(line)
end

---@package
function ft.buffer_at_line(line)
    local bufnr = ft.parse_line(line)
    return Buffer:new(bufnr)
end

---@private
function ft.parse_line(line)
    local match = string.match(line, "[(%d+)]")
    if match ~= nil then
        return tonumber(match)
    else
        error("[firvish] Failed to get buffer from '" .. line "'")
    end
end

return ft
