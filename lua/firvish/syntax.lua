local vim = vim
local cmd = vim.cmd
local M = {}

M.set_common_syntax = function()
    cmd('syntax match FirvishError "^ERROR:"')
    cmd('syntax match FirvishWarning "^WARNING:"')
    cmd('syntax match FirvishInfo "^INFO:"')

    cmd("highlight default link FirvishError ErrorMsg")
    cmd("highlight default link FirvishWarning WarningMsg")
    cmd("highlight default link FirvishInfo IncSearch")
end

return M
