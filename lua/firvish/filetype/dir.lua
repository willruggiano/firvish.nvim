---@mod firvish.filetype.dir
---@brief [[
---The buffer-local library which is passed to keymaps associated with the |firvish-dir| filetype.
---@brief ]]

local ErrorList = require "firvish.internal.error_list"
local lib = require "firvish.lib.lines"

local dir = {}

---@package
function dir.setup(bufnr)
    vim.bo[bufnr].errorformat = "%f"

    vim.keymap.set(
        "n",
        "<CR>",
        dir.open_file,
        { buffer = bufnr, desc = "[firvish] Open file under cursor", noremap = true, silent = true }
    )

    vim.keymap.set(
        { "v", "x" },
        "<CR>",
        dir.open_selected_files,
        { buffer = bufnr, desc = "[firvish] Open selected files", noremap = true, silent = true }
    )

    vim.keymap.set(
        "n",
        "x",
        dir.send_file_to_quickfix_list,
        { buffer = bufnr, desc = "[firvish] Add file to quickfix list", noremap = true, silent = true }
    )

    vim.keymap.set(
        { "x", "v" },
        "x",
        dir.send_selected_files_to_quickfix_list,
        { buffer = bufnr, desc = "[firvish] Add selected files to quickfix list", noremap = true, silent = true }
    )
end

---@package
function dir.open_file()
    local line = lib.get_cursor_line()
    vim.cmd("edit " .. line)
end

---@package
function dir.open_selected_files()
    local lines = lib.get_selected_lines()
    for _, line in ipairs(lines) do
        vim.cmd("edit " .. line)
    end
end

---@package
-- NOTE: This appends to the current quickfix list.
function dir.send_file_to_quickfix_list()
    local el = ErrorList:new("quickfix", {
        action = "a",
        efm = "%f",
        lines = lib.get_cursor_line(),
        title = "firvish-dir",
    })

    el:open()

    return el
end

---@package
-- NOTE: This appends to the current quickfix list.
function dir.send_selected_files_to_quickfix_list()
    local el = ErrorList:new("quickfix", {
        action = "a",
        efm = "%f",
        lines = lib.get_selected_lines(),
        title = "firvish-dir",
    })

    el:open()

    return el
end

return dir
