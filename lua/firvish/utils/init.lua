local vim = vim
local M = {}

M.open_firvish_buffer = function(title, filetype, options)
    vim.api.nvim_command("edit " .. title)
    local bufnr = vim.fn.bufnr()

    vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
    vim.api.nvim_buf_set_option(bufnr, "readonly", false)

    if options ~= nil and options.buflisted ~= nil then
        vim.api.nvim_buf_set_option(bufnr, "buflisted", options.buflisted)
    else
        vim.api.nvim_buf_set_option(bufnr, "buflisted", false)
    end

    vim.api.nvim_buf_set_option(bufnr, "buftype", "nowrite")
    vim.api.nvim_buf_set_option(bufnr, "filetype", filetype)

    return bufnr
end

M.create_preview_window = function(title, lines)
    vim.api.nvim_command("pedit +:let\\ g:firvish_preview_window_bufnr=bufnr() " .. title)

    local bufnr = vim.g.firvish_preview_window_bufnr
    vim.api.nvim_command "unlet g:firvish_preview_window_bufnr"

    vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
    vim.api.nvim_buf_set_option(bufnr, "buflisted", false)

    vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")

    return bufnr
end

M.set_buf_lines = function(bufnr, lines)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
end

M.jump_to_window = function(tab, window)
    vim.api.nvim_command(tab .. "tabnext")
    vim.api.nvim_command(window .. "wincmd w")
end

M.find_open_window = function(buffer)
    local current_tab = vim.fn.tabpagenr()
    local last_tab = vim.fn.tabpagenr "$"
    for tabnr = 1, last_tab, 1 do
        local buffers = vim.fn.tabpagebuflist(tabnr)
        for winnr, bufnr in ipairs(buffers) do
            if buffer == bufnr then
                return { tabnr = tabnr, winnr = winnr }
            end
        end
    end

    return { tabnr = -1, winnr = -1 }
end

M.is_window_visible = function(tabnr, bufnr)
    local buffers = vim.fn.tabpagebuflist(tabnr)
    for _, win in pairs(buffers) do
        if win == bufnr then
            return true
        end
    end

    return false
end

M.log_error = function(message)
    vim.api.nvim_command "echohl ErrorMsg"
    vim.api.nvim_command('echo "[firvish] ' .. message .. '"')
    vim.api.nvim_command "echohl Normal"
end

M.any_of = function(items, predicate)
    for _, value in pairs(items) do
        if predicate(value) == true then
            return true
        end
    end

    return false
end

M.merge_table = function(target, source)
    for _, v in ipairs(source) do
        table.insert(target, v)
    end

    return target
end

M.set_qflist = function(lines, action, bufnr, extra_efm, use_loclist)
    local result, efm = pcall(vim.api.nvim_get_option, "errorformat")
    if efm == nil then
        efm = ""
    end

    extra_efm = extra_efm or {}
    local local_efm = nil
    if bufnr ~= nil then
        result, local_efm = pcall(vim.api.nvim_buf_get_option, bufnr, "errorformat")
    end

    if efm ~= "" and local_efm ~= nil then
        efm = efm .. "," .. local_efm
    elseif local_efm ~= nil then
        efm = local_efm
    end

    efm = efm .. "," .. table.concat(extra_efm, ",")

    local parsed_entries = vim.fn.getqflist { lines = lines, efm = efm }
    if parsed_entries.items then
        if use_loclist then
            vim.fn.setloclist(bufnr, parsed_entries.items, action)
        else
            vim.fn.setqflist(parsed_entries.items, action)
        end
    end
end

function M.wrap(f0, f1)
    return function(...)
        f0(...)
        f1(...)
    end
end

local function gen_ordered_index(t)
    local ordered_index = {}
    for key in pairs(t) do
        table.insert(ordered_index, key)
    end
    table.sort(ordered_index)
    return ordered_index
end

local function ordered_next(t, state)
    local key = nil
    if state == nil then
        t.__ordered_index = gen_ordered_index(t)
        key = t.__ordered_index[1]
    else
        for i = 1, #t.__ordered_index do
            if t.__ordered_index[i] == state then
                key = t.__ordered_index[i + 1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    t.__ordered_index = nil
end

function M.sorted_pairs(t)
    return ordered_next, t, nil
end

function M.now()
    return os.date "%H:%M:%S"
end

function M.exit_visual_mode()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "x", true)
end

return M
