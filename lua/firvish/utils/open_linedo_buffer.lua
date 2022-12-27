local config = require "firvish.config"

local Buffer = require "firvish.internal.buffer"

return function(line1, line2, source_buffer, cmd, sh_mode)
    local lines = vim.api.nvim_buf_get_lines(source_buffer, line1 - 1, line2, true)
    ---@type string
    ---@diagnostic disable-next-line: assign-type-mismatch
    local shell = config.get "shell"
    local extension = "sh"

    if sh_mode == false then
        extension = "vim"
    elseif string.match(shell, "powershell") ~= nil or string.match(shell, "pwsh") ~= nil then
        extension = "ps1"
    elseif string.match(shell, "cmd") ~= nil then
        extension = "bat"
    end

    vim.api.nvim_command("silent split " .. vim.fn.tempname() .. "." .. extension)
    local buffer = Buffer:new(vim.fn.bufnr())

    local command_lines = {}
    for index, line in pairs(lines) do
        command_lines[index] = string.gsub(cmd, "{}", '"' .. line .. '"')
    end

    buffer:set_option("modifiable", true)
    buffer:set_option("readonly", false)
    buffer:set_option("buflisted", false)

    vim.cmd "setlocal cursorline"

    buffer:set_keymap("n", "E!", function()
        vim.cmd "silent write"
        require("firvish").run_commands(buffer, sh_mode)
    end, { noremap = true, silent = true })

    buffer:set_lines(command_lines)
    vim.cmd "silent write"

    return buffer
end
