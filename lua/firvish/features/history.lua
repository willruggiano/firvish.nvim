---@mod firvish.history History
---@tag :History
---@brief [[
---History stuff
---@brief ]]

local utils = require "firvish.utils"

local history = {}

---@package
function history.setup()
    vim.api.nvim_create_user_command("History", history.open_history, {})
end

local open_bufnr = nil

function get_history(predicate)
    local old_files = vim.api.nvim_get_vvar "oldfiles"
    local history = {}
    for index, file in ipairs(old_files) do
        if vim.fn.filereadable(file) == 1 and (predicate == nil or (predicate ~= nil and predicate(file) == true)) then
            history[#history + 1] = vim.fn.fnamemodify(file, ":p:~:.")
        end
    end

    return history
end

history.on_buf_delete = function()
    open_bufnr = nil
end

history.on_buf_leave = function()
    previous_bufnr = nil
end

history.close_history = function()
    if previous_bufnr ~= nil then
        vim.api.nvim_command("buffer " .. previous_bufnr)
    else
        vim.api.nvim_command("bwipeout! " .. open_bufnr)
        open_bufnr = nil
    end

    previous_bufnr = nil
end

history.open_history = function()
    local tabnr = vim.fn.tabpagenr()
    previous_bufnr = vim.api.nvim_get_current_buf()

    if open_bufnr == nil then
        vim.api.nvim_command "e firvish-history"
        open_bufnr = vim.api.nvim_get_current_buf()
        history.refresh_history()
    elseif utils.is_window_visible(tabnr, open_bufnr) then
        vim.api.nvim_command(vim.fn.bufwinnr(open_bufnr) .. "wincmd w")
        history.refresh_history()
    else
        vim.api.nvim_command("buffer " .. open_bufnr)
        history.refresh_history()
    end
end

history.refresh_history = function()
    utils.set_buf_lines(open_bufnr, get_history(nil))
end

history.open_file = function()
    local linenr = vim.fn.line "."
    local lines = vim.api.nvim_buf_get_lines(open_bufnr, linenr - 1, linenr, true)
    vim.api.nvim_command("edit " .. lines[1])
end

return history
