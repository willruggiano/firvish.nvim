local Buffer = require "firvish.internal.buffer"

local buffers = {}

function buffers.iter()
    local l = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        table.insert(l, Buffer:new(bufnr))
    end
    return ipairs(l)
end

return buffers
