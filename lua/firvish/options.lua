local vim = vim
local g = vim.g
local log = require("firvish.log")

local s_options = {
    always_preview = {
        default = false,
    },
    use_default_mappings = {
        default = false,
    },
    shell = {
        default = function()
            return vim.opt.shell:get()
        end,
    },
}

local function get_default(opt)
    if type(opt.default) == "function" then
        return opt.default()
    end

    return opt.default
end

local options = {}

setmetatable(options, {
    __index = function(_, name)
        local opt = s_options[name]
        if opt == nil then
            log.error("Option is not found:" .. name)
            return nil
        end

        local value = g[name]
        if value == nil and not opt.nullable then
            return get_default(opt)
        end

        return g[name]
    end,
})

return options
