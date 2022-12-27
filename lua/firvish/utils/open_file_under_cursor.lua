---@param nav_direction string
---@param preview boolean
---@param reuse_window boolean
---@param vertical boolean
return function(nav_direction, preview, reuse_window, vertical)
    if reuse_window then
        local current_winnr = vim.fn.winnr()
        vim.api.nvim_command "wincmd l"
        if vim.fn.winnr() ~= current_winnr then
            vim.api.nvim_command "normal q"
        end
    end

    if vertical then
        vim.api.nvim_command "vertical normal ^F"
    else
        vim.api.nvim_command "normal ^F"
    end

    if preview then
        vim.api.nvim_command "wincmd p"
    end

    if nav_direction == "down" then
        vim.api.nvim_command "normal j"
    elseif nav_direction == "up" then
        vim.api.nvim_command "normal k"
    end
end
