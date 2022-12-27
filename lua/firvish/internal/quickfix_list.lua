---@class QuickfixList
---@field context table
---@field efm string
---@field title string
local QuickfixList = {}
QuickfixList.__index = QuickfixList

function QuickfixList:new(opts)
    local obj = setmetatable({
        context = opts.context,
        efm = opts.efm or vim.api.nvim_get_option "errorformat",
        title = opts.title,
    }, self)
    return obj
end

function QuickfixList:set(opts)
    vim.fn.setqflist(
        {},
        "r", -- N.B. Replaces current quickfix list
        {
            context = self.context,
            lines = opts.lines,
            efm = opts.efm or self.efm,
            title = self.title,
        }
    )
end

function QuickfixList:open()
    vim.api.nvim_command "botright cwindow"
end

function QuickfixList:close()
    vim.api.nvim_command "cclose"
end

return QuickfixList
