local function exit_visual_mode()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "x", true)
end

local lines = {}

function lines.get_cursor_line()
    local index = vim.fn.line "."
    return vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), index - 1, index, true)[1]
end

function lines.get_selected_lines()
    local line1, line2 = lines.get_visual_selection()
    return vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), line1 - 1, line2, true)
end

function lines.get_visual_selection()
    exit_visual_mode()
    return vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2]
end

return lines
