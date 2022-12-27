local config = require "firvish.config"

---@param buffer Buffer
---@param sh_mode boolean
return function(buffer, sh_mode)
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
        require("firvish.job_control2").start_job {
            command = { shell },
            args = args,
            filetype = "firvish-job",
            title = "fhdo",
        }
        vim.api.nvim_command("bwipeout! " .. buffer.bufnr)
    else
        local lines = buffer:lines()
        vim.api.nvim_command "wincmd p"
        vim.api.nvim_command("bwipeout! " .. buffer.bufnr)

        for _, line in pairs(lines) do
            vim.api.nvim_command(line)
        end
    end
end
