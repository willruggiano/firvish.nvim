---@mod firvish.fh Fh
---@tag :Fhdo
---@tag :Fhfilter
---@tag :Fhq
---@tag :Fhl
---@brief [[
---Fh stuff
---@brief ]]

local config = require "firvish.config"
local Buffer = require "firvish.internal.buffer"

local fh = {}

---@package
function fh.setup()
    vim.api.nvim_create_user_command("Fhdo", function(args)
        fh.do_(args.line1, args.line2, vim.fn.bufnr(), args.fargs, args.bang == false)
    end, { complete = "file", nargs = "*" })

    vim.api.nvim_create_user_command("Fhfilter", function(args)
        fh.filter(args.line1, args.line2, args.bang == false, args.args)
    end, { bang = true, bar = true, nargs = "*", range = true })

    vim.api.nvim_create_user_command("Fhq", function(args)
        fh.send_to_errorlist(args.line1 - 1, args.line2, args.bang, "quickfix")
    end, { bang = true, bar = true, range = true })

    vim.api.nvim_create_user_command("Fhl", function(args)
        fh.send_to_errorlist(args.line1 - 1, args.line2, args.bang, "loclist")
    end, { bang = true, bar = true, range = true })
end

function fh.filter(line1, line2, bang, args)
    --
end

function fh.send_to_errorlist(line1, line2, bang, errorlist)
    --
end

local function fhdo(buffer, sh_mode)
    if sh_mode == true then
        ---@type string
        ---@diagnostic disable-next-line: assign-type-mismatch
        local shell = config.get "shell"
        local args = {}
        if string.match(shell, "powershell") ~= nil or string.match(shell, "pwsh") ~= nil then
            table.insert(args, "-NoLogo")
            table.insert(args, "-NonInteractive")
            table.insert(args, "-NoProfile")
            table.insert(args, "-ExecutionPolicy")
            table.insert(args, "RemoteSigned")
            table.insert(args, "-File")
        end

        table.insert(args, vim.fn.expand "%")
        require("firvish.jobs").start_job {
            command = { shell },
            args = args,
            filetype = "firvish-job",
            title = "fhdo",
        }
        vim.api.nvim_command("bwipeout! " .. buffer.bufnr)
    else
        local lines = buffer:get_lines(0, -1, false)
        vim.api.nvim_command "wincmd p"
        vim.api.nvim_command("bwipeout! " .. buffer.bufnr)

        for _, line in pairs(lines) do
            vim.api.nvim_command(line)
        end
    end
end

function fh.do_(line1, line2, source_buffer, cmd, sh_mode)
    if type(source_buffer) == "number" then
        source_buffer = Buffer:new(source_buffer)
    end

    local lines = source_buffer:lines(line1 - 1, line2)
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

    buffer:set_option("buflisted", false)
    buffer:set_option("modifiable", true)
    buffer:set_option("readonly", false)

    vim.cmd "setlocal cursorline"

    buffer:set_keymap("n", "E!", function()
        vim.cmd "silent write"
        fhdo(buffer, sh_mode)
    end, { noremap = true, silent = true })

    buffer:set_lines(command_lines)
    vim.cmd "silent write"

    return buffer
end

return fh
