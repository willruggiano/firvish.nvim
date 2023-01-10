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
---  * buffers - creates a |:Buffers| command which opens the buffer list
---  * fh - creates several commands (|:Fhdo|, |:Fhfilter|, |:Fhq| and |:Fhl|) which allow you to
---    interact with a buffer displaying files (see: |firvish-dir|)
---  * find - creates three commands (|:Fd|, |:Cfd| and |:Lfd|) that captures the output of running
---    `fd` in a dedicated buffer (see: |firvish-dir|), the quickfix list or the location list
---    respectively. Requires `fd` (https://github.com/sharkdp/fd) to be installed
---  * frun - creates three commands (|:Frun|, |:Cfrun| and |:Lfrun|) that captures the output of an
---    arbitrary command in a dedicate buffer (see: |firvish-job|), the quickfix list or the location
---    list respectively
---  * grep - creates three commands (|:Rg|, |:Crg| and |:Lrg|) that captures the output of running
---    `rg` in a dedicated buffer (see: |firvish-dir|), the quickfix list or the location list
---    respectively. Requires `rg` (https://github.com/BurntSushi/ripgrep) to be installed
---  * history - creates a |:History| command which shows recently opened files in a dedicated
---    buffer (see: |firvish-dir|)
---  * jobs - creates a |:FirvishJobs| command which shows jobs started via Firvish's jobs module.
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
---  features = true,
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

local function enable(features, feature)
    return features == true or features[feature] == true or type(features[feature]) == "table"
end

---Configure the plugin by calling the `setup()` function
---@param opts table
---@usage `require("firvish").setup { ... }`
---@see firvish.features
function firvish.setup(opts)
    if opts.features then
        for _, feature in ipairs(features) do
            if enable(opts.features, feature) then
                require("firvish.features." .. feature).setup(opts.features[feature])
            end
        end
    end
end

return firvish
