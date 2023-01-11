---@mod firvish.lib.fhdo Fhdo API
---@brief [[
---The fhdo API provides functions which can be used to create a script from a buffer's lines, and
---subsequently execute it.
---@brief ]]

local Buffer = require "firvish.internal.buffer"

local fhdo = {}

local function make_source_buffer(opts)
    if type(opts.source) == "number" then
        return Buffer:new(opts.source)
    else
        return opts.source
    end
end

---Generate a (sh|vim) script.
---@param opts table
---@return Buffer
function fhdo.generate(opts)
    local source_buffer = make_source_buffer(opts)

    ---@type string
    ---@diagnostic disable-next-line: assign-type-mismatch
    local shell = vim.opt.shell:get()
    local extension = "sh"

    if opts.script.vim == true then
        extension = "vim"
    elseif string.match(shell, "powershell") ~= nil or string.match(shell, "pwsh") ~= nil then
        extension = "ps1"
    elseif string.match(shell, "cmd") ~= nil then
        extension = "bat"
    end

    vim.api.nvim_command("silent " .. (opts.open or "split") .. " " .. vim.fn.tempname() .. "." .. extension)
    local buffer = Buffer:new(vim.api.nvim_get_current_buf())

    local line1, line2 = unpack(opts.range)
    local lines = source_buffer:get_lines(line1 - 1, line2)
    local command_lines = {}
    if extension == "sh" then
        table.insert(command_lines, [[#!/usr/bin/env sh]])
    end

    local cmd = opts.command
    for _, line in pairs(lines) do
        ---@diagnostic disable-next-line: redefined-local
        local line, _ = string.gsub(cmd, "{}", line)
        table.insert(command_lines, line)
    end

    buffer:set_option("bufhidden", "wipe")
    buffer:set_option("buflisted", false)
    buffer:set_option("modifiable", true)
    buffer:set_option("readonly", false)

    if opts.script.keymaps then
        buffer:apply_keymaps(opts.script.keymaps)
    end

    buffer:set_lines(command_lines)
    buffer:bufdo "silent write"

    return buffer
end

---Execute a script generated with |firvish.lib.fhdo.generate|
---@param buffer Buffer|number
---@usage [[
---local buffer = Buffer:new(vim.api.nvim_get_current_buf())
---require("firvish.lib.fhdo").exec(buffer)
---@usage ]]
function fhdo.exec(buffer)
    if type(buffer) == "number" then
        buffer = Buffer:new(buffer)
    end

    local is_vim = buffer:name ":e" == "vim"

    if is_vim then
        local lines = buffer:get_lines(0, -1, false)
        vim.api.nvim_command "wincmd p"

        for _, line in pairs(lines) do
            vim.api.nvim_command(line)
        end
    else
        local args = {}
        table.insert(args, buffer:name())
        require("firvish.jobs").start_job {
            command = vim.opt.shell:get(),
            args = args,
            filetype = "firvish-job",
            title = "fhdo",
        }
    end
end

return fhdo
