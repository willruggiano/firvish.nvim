---@mod firvish.fh Fh
---@brief [[
---The "fh" feature provides several commands that ... ???
---@brief ]]

---@tag :Fhdo
---@brief [[
---:[range]Fhdo[!] {cmd}
---    Generates a script with {cmd} applied to [range] and the respective filepath
---    inserted wherever {} appears in {cmd}. If bang ! is given, the resulting script is a vim
---    script, otherwise it is a shell script.
---
---    For example, to rename a list of visual-selected files: >
---        :'<,'>Fhdo mv {} {}-copy.txt
---<    Run the script with |E!| or `:!%`
---@brief ]]
---@see vim.opt.shell

local lib = require "firvish.lib"

local fh = {}

fh.config = {
    open = "split",
    keymaps = {
        n = {
            ["Z!"] = {
                function()
                    vim.cmd "silent write"
                    lib.fhdo.exec(vim.api.nvim_get_current_buf())
                end,
                { desc = "[firvish] Execute script" },
            },
        },
    },
}

local function make_range(args)
    local line1 = args.line1
    local line2 = args.line2
    if line1 == line2 then
        line1 = 0
        line2 = -1
    end
    return line1, line2
end

---@package
function fh.setup()
    vim.api.nvim_create_user_command("Fhdo", function(args)
        local line1, line2 = make_range(args)
        lib.fhdo.generate {
            source = vim.api.nvim_get_current_buf(),
            command = args.args,
            open = fh.config.open,
            range = { line1, line2 },
            script = {
                keymaps = fh.config.keymaps,
                vim = args.bang,
            },
        }
    end, { bang = true, complete = "file", nargs = "*", range = true })
end

return fh
