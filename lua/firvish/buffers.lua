local utils = require "firvish.utils"

local M = {}

M.bufnr = nil
M.buffer_list_dirty = false
M.cached_buffers = {}

local function create_buffer_list(predicate)
    if M.buffer_list_dirty == false then
        return M.cached_buffers
    end

    local buffers = {}
    local all_buffers = vim.fn.range(1, vim.fn.bufnr "$")
    local buf_num_length = #tostring(#all_buffers)

    for _, bufnr in ipairs(all_buffers) do
        if
            vim.fn.buflisted(bufnr) == 1
            and bufnr ~= M.bufnr
            and (predicate == nil or (predicate ~= nil and predicate(bufnr) == true))
        then
            local bufnr_str = "[" .. bufnr .. "]"
            local line = bufnr_str
            local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
            local bufname = vim.fn.bufname(bufnr)
            bufname = vim.fn.fnamemodify(bufname, ":p:~:.")

            if modified then
                line = line .. " +"
            end

            line = line .. string.rep(" ", buf_num_length - (#bufnr_str - 2) + 1)
            if bufname == "" then
                line = line .. "[No Name]"
            else
                line = line .. bufname
            end

            buffers[#buffers + 1] = line
        end
    end

    M.cached_buffers = buffers
    M.buffer_list_dirty = false
    return M.cached_buffers
end

local function get_bufnr(linenr)
    local line = vim.fn.getbufline(M.bufnr, linenr)[1]
    local bufnr = vim.fn.substitute(vim.fn.matchstr(line, "[[0-9]\\+]"), "\\(\\[\\|\\]\\)", "", "g")

    if bufnr ~= "" then
        return tonumber(bufnr)
    end

    local buffer_name = string.sub(line, vim.fn.matchstrpos(line, "[A-Za-z]")[2], -1)
    local buffer_name = vim.fn.trim(buffer_name)
    bufnr = vim.fn.bufnr(buffer_name)

    if bufnr == -1 then
        utils.log_error "Cannot read buffer number from the list."
        return -1
    end

    return tonumber(bufnr)
end

M.on_buf_delete = function()
    M.bufnr = nil
end

M.on_buf_enter = M.open_buffers

M.on_buf_leave = function() end

M.mark_dirty = function()
    M.buffer_list_dirty = true
end

M.jump_to_buffer = function()
    local bufnr = get_bufnr(vim.fn.line ".")
    if bufnr == -1 then
        return
    end

    local jump_info = utils.find_open_window(bufnr)
    if jump_info.tabnr ~= -1 and jump_info.winnr ~= -1 then
        utils.jump_to_window(jump_info.tabnr, jump_info.winnr)
    else
        vim.api.nvim_command("buffer " .. bufnr)
    end
end

M.bufnr = nil
M.open_buffers = function()
    if M.bufnr == nil then
        vim.api.nvim_command "e firvish://buffers"
        M.bufnr = vim.fn.bufnr()
    elseif utils.is_window_visible(vim.fn.tabpagenr(), M.bufnr) then
        vim.api.nvim_command(vim.fn.bufwinnr(M.bufnr) .. "wincmd w")
    else
        vim.api.nvim_command("buffer " .. M.bufnr)
    end
    M.refresh_buffers()
end

M.refresh_buffers = function()
    assert(M.bufnr ~= nil, "Invariant violated: call to refresh_buffers() prior to open_buffers()")
    local lines = create_buffer_list()
    local cursor = vim.api.nvim_win_get_cursor(0)
    utils.set_buf_lines(M.bufnr, lines)

    if cursor[1] > #lines then
        cursor[1] = #lines - 1
    end

    if cursor[1] > 0 then
        vim.api.nvim_win_set_cursor(0, cursor)
    end
end

M.filter_buffers = function(mode)
    local buffers = nil
    M.buffer_list_dirty = true
    if mode == "modified" then
        buffers = create_buffer_list(function(bufnr)
            return vim.api.nvim_buf_get_option(bufnr, "modified")
        end)
    elseif mode == "current_tab" then
        local tabnr = vim.fn.tabpagenr()
        buffers = create_buffer_list(function(bufnr)
            return utils.is_window_visible(tabnr, bufnr)
        end)
    elseif mode == "args" then
        local args = vim.fn.argv()
        local args_bufnr = {}
        for index, arg in ipairs(args) do
            args_bufnr[index] = vim.fn.bufnr(arg)
        end

        buffers = create_buffer_list(function(bufnr)
            return utils.any_of(args_bufnr, function(v)
                return v == bufnr
            end)
        end)
    elseif type(mode) == "function" then
        buffers = create_buffer_list(mode)
    else
        assert(false, "Unsupported filter type: " .. mode)
    end

    utils.set_buf_lines(M.bufnr, buffers)
end

M.buf_do = function(start_line, end_line, cmd)
    for linenr = start_line, end_line, 1 do
        vim.api.nvim_command("buffer " .. get_bufnr(linenr))
        vim.api.nvim_command(cmd)
    end

    vim.api.nvim_command("buffer " .. M.bufnr)
end

M.buf_delete = function(start_line, end_line, force)
    local start_buffer = get_bufnr(start_line)
    local end_buffer = get_bufnr(end_line)

    if not force then
        vim.api.nvim_command(start_buffer .. "," .. end_buffer .. "bdelete")
    else
        vim.api.nvim_command(start_buffer .. "," .. end_buffer .. "bdelete!")
    end

    M.refresh_buffers()
end

M.buf_count = function()
    local buffers = create_buffer_list()
    return #buffers
end

M.setup = function(bufnr)
    local winnr = assert(vim.fn.bufwinnr(bufnr), "no window for buffer " .. bufnr)

    -- vim.api.nvim_buf_set_option(winnr, "cursorline", true)
    vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
    vim.api.nvim_buf_set_option(bufnr, "buflisted", true)
    vim.api.nvim_buf_set_option(bufnr, "syntax", "firvish-buffers")
    vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(bufnr, "swapfile", false)

    require("firvish.config").apply_mappings("buffers", bufnr)

    vim.api.nvim_buf_create_user_command(bufnr, "Bufdo", function(args)
        M.buf_do(args.line1, args.line2, args.fargs)
    end, { nargs = "*", range = true })

    vim.api.nvim_buf_create_user_command(bufnr, "Bdelete", function(args)
        M.buf_delete(args.line1, args.line2, args.bang)
    end, { bang = true, nargs = "*", range = true })

    local augroup = vim.api.nvim_create_augroup("firvish-buffers", { clear = true })

    vim.api.nvim_create_autocmd("BufEnter", {
        buffer = bufnr,
        callback = function()
            M.on_buf_enter()
        end,
        group = augroup,
    })

    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
        buffer = bufnr,
        callback = function()
            M.on_buf_delete()
        end,
        group = augroup,
    })

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = bufnr,
        callback = function()
            M.on_buf_leave()
        end,
        group = augroup,
    })
end

return M
