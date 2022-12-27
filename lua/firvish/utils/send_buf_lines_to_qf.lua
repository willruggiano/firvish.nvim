local Buffer = require "firvish.internal.buffer"
local ErrorList = require "firvish.internal.error_list"

---@param line1 number
---@param line2 number
---@param replace boolean
---@param errorlist string
return function(line1, line2, replace, errorlist)
    errorlist = errorlist or "quickfix"
    local buffer = Buffer:new(vim.api.nvim_get_current_buf())
    return ErrorList:from_buf_lines(errorlist, buffer, line1, line2, {
        action = replace and "r" or "a",
    })
end
