local config = require "firvish.config"
local Buffer = require "firvish.internal.buffer"

---@class BufferListBuffer
---@field buffer Buffer
---@field buffer_list BufferList
---@field state Buffer[]
local BufferListBuffer = {}
BufferListBuffer.__index = BufferListBuffer

---@param buffer_list BufferList
function BufferListBuffer:new(buffer_list, on_buf_delete)
    local buffer = Buffer:new(vim.api.nvim_create_buf(false, true), "[Firvish Buffers]")
    buffer:set_option("filetype", "firvish-buffers")
    buffer:create_autocmd({ "BufDelete", "BufWipeout" }, {
        callback = on_buf_delete,
    })

    config.apply_mappings("buffers", buffer)

    local obj = setmetatable({
        buffer = buffer,
        buffer_list = buffer_list,
        state = {},
    }, self)

    obj:setup_()

    return obj
end

function BufferListBuffer:setup_()
    self.buffer:create_autocmd("BufEnter", {
        callback = function()
            -- NOTE: Whenever we open the buffer, call refresh()
            self:refresh()
        end,
    })
    self.buffer:create_user_command("Bufdo", function(args)
        self:bufdo(args.line1, args.line2, args.fargs)
    end, { nargs = "*", range = true })

    self.buffer:create_user_command("Bdelete", function(args)
        self:bdelete(args.line1, args.line2, args.bang)
    end, { bang = true, nargs = "*", range = true })
end

function BufferListBuffer:change_to(buffer)
    vim.api.nvim_command("buffer " .. buffer.bufnr)
end

function BufferListBuffer:bufdo(line1, line2, fargs)
    for linenr = line1, line2, 1 do
        self:buffer_at(linenr):bufdo(fargs)
    end
end

function BufferListBuffer:bdelete(line1, line2, force)
    for linenr = line1, line2, 1 do
        self:buffer_at(linenr):bdelete(force)
    end
    self:refresh()
end

function BufferListBuffer:jump_to_buffer(linenr)
    self.state[linenr]:open()
end

function BufferListBuffer:buffer_at(linenr)
    return self.state[linenr]
end

function BufferListBuffer:open()
    self.buffer:open()
end

function BufferListBuffer:refresh_(buffer_list)
    assert(buffer_list ~= nil, "buffer_list == nil")
    -- NOTE: We must take care to update the state before every call to buf_set_lines()
    -- We depend on the state when, for example, doing a jump_to_buffer()
    self.state = buffer_list:sorted()
    self.buffer:set_lines(buffer_list:lines())
end

function BufferListBuffer:refresh()
    self:refresh_(self.buffer_list)
end

function BufferListBuffer:filter(f)
    local buffer_list = self.buffer_list:filter(f)
    self:refresh_(buffer_list)
end

function BufferListBuffer:rename_buffer(linenr, bufname)
    self:buffer_at(linenr):rename(bufname)
    self:refresh()
end

return BufferListBuffer
