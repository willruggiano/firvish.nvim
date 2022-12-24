local utils = require "firvish.utils"

---@class Buffer
---@field bufnr number
local Buffer = {}
Buffer.__index = Buffer

function Buffer:new(bufnr, name)
    if name ~= nil then
        vim.api.nvim_buf_set_name(bufnr, name)
    end

    local obj = {
        bufnr = bufnr,
    }

    return setmetatable(obj, self)
end

function Buffer:listed()
    return self:get_option "buflisted"
end

function Buffer:modified()
    return self:get_option "modified"
end

function Buffer:visible()
    return vim.fn.bufwinnr(self.bufnr) ~= -1
end

function Buffer:name()
    return vim.fn.fnamemodify(vim.fn.bufname(self.bufnr), "p:~:.")
end

function Buffer:filetype()
    return self:get_option "filetype"
end

function Buffer:create_autocmd(event, opts)
    vim.api.nvim_create_autocmd(event, vim.tbl_deep_extend("force", { buffer = self.bufnr }, opts))
end

function Buffer:on_buf_delete(f)
    self:create_autocmd({ "BufDelete", "BufWipeout" }, {
        callback = f,
    })
end

function Buffer:create_user_command(...)
    vim.api.nvim_buf_create_user_command(self.bufnr, ...)
end

function Buffer:get_option(key)
    return vim.api.nvim_buf_get_option(self.bufnr, key)
end

function Buffer:set_option(key, value)
    vim.api.nvim_buf_set_option(self.bufnr, key, value)
end

function Buffer:is_same(other)
    if type(other) == "number" then
        return self.bufnr == other
    else
        return self.bufnr == other.bufnr
    end
end

function Buffer:line(linenr)
    return vim.fn.getbufline(self.bufnr, linenr)[1]
end

function Buffer:append(line)
    vim.fn.appendbufline(self.bufnr, "$", line)
end

function Buffer:set_lines(lines)
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, true, lines)
end

function Buffer:open()
    if utils.is_window_visible(vim.fn.tabpagenr(), self.bufnr) then
        vim.api.nvim_command(vim.fn.bufwinnr(self.bufnr) .. "wincmd w")
    else
        vim.api.nvim_command("buffer " .. self.bufnr)
    end
end

function Buffer:set_keymap(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, vim.tbl_deep_extend("force", { buffer = self.bufnr }, opts))
end

function Buffer:bufdo(cmd)
    vim.api.nvim_command(cmd)
    return self
end

function Buffer:bdelete(force)
    if force then
        vim.api.nvim_command("silent bdelete! " .. self.bufnr)
    else
        vim.api.nvim_command("silent bdelete " .. self.bufnr)
    end
end

function Buffer:rename(bufname)
    vim.api.nvim_buf_set_name(self.bufnr, bufname)
end

return Buffer
