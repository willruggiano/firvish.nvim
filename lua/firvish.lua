---@mod firvish Introduction
---@brief [[
---
---This plugin is heavily inspired by [vim-dirvish](https://github.com/justinmk/vim-dirvish).
---
---firvish.nvim is a buffer centric job control plugin. It provides mappings for handling buffer list, history, neovim and external commands. The output of these commands can be streamed to a dedicated buffer and/or an errorlist (e.g. a quickfix list or location list).
---
---The main goal of firvish.nvim is to provide a single way of interacting with external commands, and internal commands of NeoVim through the use of buffers. They are used to interact with the output of commands, and the input is sent to external commands to interactively communicate with them.
---
---See the documentation for more details.
---@brief ]]

---@mod firvish.features Features
---@brief [[
---Firvish is split into features, which can enabled on an individual basis and correspond to user
---commands. Firvish does NOT create keymappings except in Firvish specific buffers (e.g. |firvish-buffers|).
---
---These are the currently available features:
---  * buffers - see |firvish.features.buffers|
---  * fh - see |firvish.features.fh|
---  * find - see |firvish.features.find|
---  * frun - see |firvish.features.frun|
---  * grep - see |firvish.features.grep|
---  * history - see |firvish.features.history|
---  * jobs - see |firvish.features.jobs|
---
---Features can be enabled or disabled individually through |firvish.setup|:
---
--->
---require("firvish").setup {
---  features = {
---    buffers = true,  -- Enables the "buffer" feature
---    history = false, -- Disables the "history" feature
---  },
---}
---<
---
---You can also enable all features:
---
--->
---require("firvish").setup {
---  features = true, -- Enables all features
---}
---<
---
---@brief ]]
---
---@see firvish.setup
---@see firvish.buffers
---@see firvish.fh
---@see firvish.find
---@see firvish.frun
---@see firvish.grep
---@see firvish.history
---@see firvish.jobs

local firvish = {}

local features = { "buffers", "fh", "find", "frun", "grep", "history", "jobs" }

local function enable(feats, feature)
    return feats == true or feats[feature] == true or type(feats[feature]) == "table"
end

---Configure the plugin by calling the `setup()` function
---@param opts table
---@usage `require("firvish").setup { ... }`
---@see firvish.features
function firvish.setup(opts)
    if opts.features then
        for _, feature in ipairs(features) do
            if enable(opts.features, feature) then
                if type(opts.features) == "table" then
                    require("firvish.features." .. feature).setup(opts.features[feature])
                else
                    require("firvish.features." .. feature).setup()
                end
            end
        end
    end
end

return firvish
