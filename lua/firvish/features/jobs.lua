---@mod firvish.features.jobs Job Control
---@brief [[
---Firvish offers builtin job control functionality which is basically a wrapper around Neovim's
---builtin |job-control|. The job list is again just a normal vim buffer and you can manipulate it
---using normal vim commands. For example, you can |dd| a few lines to delete those jobs from the
---job list.
---
---The job list can be configured through |firvish.setup|. By default, it has the following
---configuration:
---
--->
---require("firvish").setup {
---    features = {
---        jobs = {
---            behavior = {
---                -- Specifies how to open the job list when using the |:FirvishJobs| command
---                -- or the Lua API.
---                open = "pedit",
---                -- Specifies how to open the buffer list when bang ! is given to the
---                -- |:FirvishJobs|
---                -- command.
---                bang_open = "vert pedit",
---            },
---            keymaps = {
---                -- See |firvish-jobs-keymaps|
---            },
---        },
---    },
---}
---<
---
---@brief ]]
---@see firvish-jobs
---@see firvish-job-api

---@tag :FirvishJobs
---@brief [[
---:FirvishJobs[!]
---    Open the job list.
---    If bang ! is given, will use the alternate open behavior:
---    `features.jobs.behavior.bang_open`
---
---@brief ]]

---@tag firvish-jobs
---@tag firvish-jobs-keymaps
---@brief [[
---The firvish-jobs filetype is used when viewing the job list.
---
---Default mappings ~
---    <CR>    Open the job preview window for the job under the cursor
---    <C-v>   Open the job preview window for the job under the cursor in a vertical split
---
---Mappings can be configured through |firvish.setup|. Assigning a mapping to `false` disables it.
---When configuring mappings through |firvish.setup|, you must specify a callback function. This
---callback function will receive the buffer-local lib (|firvish.filetype.jobs|) which can be used to
---perform common actions relevant to the job list.
---
--->
---require("firvish").setup {
---    features = {
---        jobs = {
---            keymaps = {
---                n = {
---                    gm = {
---                        callback = function(lib)
---                            -- Filter the buffer list to show only modified files
---                            local is_modified = Filter:new(function(buffer)
---                                return buffer:get_option "modified" == true
---                            end)
---                            lib.refresh(is_modified)
---                        end,
---                        desc = "[firvish] Filter modified files",
---                    },
---                },
---            },
---        },
---    },
---}
---<
---
---@brief ]]

local jobs = {}

jobs.config = {
    behavior = {
        open = "pedit",
        bang_open = "vert pedit",
    },
    filter = function()
        return true
    end,
    keymaps = {
        n = {
            ["<CR>"] = {
                callback = function(lib)
                    lib.preview_job "pedit"
                end,
                desc = "[firvish] Open preview for job under cursor",
            },
            ["<C-v>"] = {
                callback = function(lib)
                  lib.preview_job "vert pedit"
                end,
                desc = "[firvish] Open preview for job under cursor in a vertical split",
            },
            -- TODO: It might be nice to get this working.
            -- ["g."] = {
            --     callback = function(lib)
            --         local filter = Filter:new(function(job)
            --             --
            --         end)
            --         lib.refresh(filter)
            --     end,
            -- },
        },
    },
}

local filename = "firvish://jobs"

---@package
function jobs.setup(opts)
    jobs.config = vim.tbl_deep_extend("force", jobs.config, opts or {})

    vim.filetype.add {
        filename = {
            [filename] = "firvish-jobs",
        },
    }

    vim.api.nvim_create_user_command("FirvishJobs", function(args)
        if args.bang then
            vim.cmd(jobs.config.behavior.bang_open .. " " .. filename)
        else
            vim.cmd(jobs.config.behavior.open .. " " .. filename)
        end
    end, { bang = true })
end

return jobs
