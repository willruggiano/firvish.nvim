---@class Buffer
---@field bufnr number
---@field lines string[]
local Buffer = {}
Buffer.__index = Buffer

function Buffer:new(bufnr, name)
    if name ~= nil then
        vim.api.nvim_buf_set_name(bufnr, name)
    end

    local obj = {
        bufnr = bufnr,
        lines = {},
    }

    return setmetatable(obj, self)
end

function Buffer:listed()
    return self:get_option "buflisted"
end

function Buffer:loaded()
    return vim.api.nvim_buf_is_loaded(self.bufnr)
end

function Buffer:modified()
    return self:get_option "modified"
end

function Buffer:valid()
    return vim.api.nvim_buf_is_valid(self.bufnr)
end

function Buffer:visible()
    return vim.fn.bufwinnr(self.bufnr) ~= -1
end

function Buffer:name(mods)
    return vim.fn.fnamemodify(vim.fn.bufname(self.bufnr), mods or ":p:~:.")
end

function Buffer:filetype()
    return self:get_option "filetype"
end

function Buffer:winnr()
    return vim.fn.bufwinnr(self.bufnr)
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

function Buffer:set_options(options)
    for k, v in pairs(options) do
        self:set_option(k, v)
    end
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

---@param start number?
---@param end_ number?
---@param strict_indexing boolean?
---@see vim.api.nvim_buf_get_lines
function Buffer:get_lines(start, end_, strict_indexing)
    start = (start == nil) and 0 or start
    end_ = (end_ == nil) and -1 or end_
    strict_indexing = (strict_indexing == nil) and true or strict_indexing
    ---@diagnostic disable-next-line: param-type-mismatch
    return vim.api.nvim_buf_get_lines(self.bufnr, start, end_, strict_indexing)
end

function Buffer:append(line)
    table.insert(self.lines, line)
    self:set_lines_()
end

function Buffer:set_lines(lines)
    self.lines = lines
    self:set_lines_()
end

---@private
function Buffer:set_lines_()
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.lines)
end

---Filter a buffer's lines.
---See |:g|
---@param line1 number line range start
---@param line2 number line range end
---@param pattern string regex
---@param matching boolean when true, remove lines matching the pattern, else remove lines NOT
---matching the pattern
---@param yank boolean when true, uses the `:d` command, else uses the `:d_` command
---@usage [[
---buffer:filter_lines(0, -1, "lua", true) -- Only lines without "lua" in them
---@usage ]]
function Buffer:filter_lines(line1, line2, pattern, matching, yank)
    local bang = matching and "" or "!"
    local clobber = yank and "d" or "d_"
    if line1 == line2 then
        self:bufdo("execute '%g" .. bang .. "/" .. pattern .. "/" .. clobber .. "'")
    else
        self:bufdo("execute '" .. line1 .. "," .. line2 .. "g" .. bang .. "/" .. pattern .. "/" .. clobber .. "'")
    end
end

---@param how string Any full (unabbreviated) buffer opening command, e.g. `:edit`, `:split`, `:vert pedit`, etc.
function Buffer:open(how)
    local winnr = self:winnr()
    if winnr ~= -1 then
        vim.api.nvim_command(winnr .. "wincmd w")
    else
        if how ~= nil and how ~= "edit" then
            if string.match(how, "pedit") then
                vim.api.nvim_command(how .. " " .. self:name())
                vim.api.nvim_command(self:winnr() .. "wincmd w")
                return self
            else
                vim.api.nvim_command(how)
            end
        end
        vim.api.nvim_command("buffer " .. self.bufnr)
        return self
    end
end

function Buffer:set_keymap(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, vim.tbl_deep_extend("force", { buffer = self.bufnr }, opts))
end

local default_opts = { noremap = true, silent = true }
function Buffer:apply_keymaps(modemaps)
    for mode, mappings in pairs(modemaps) do
        for lhs, map in pairs(mappings) do
            if map then
                local rhs = type(map) == "table" and map[1] or map
                local opts = type(map) == "table" and map[2] or {}
                self:set_keymap(mode, lhs, rhs, vim.tbl_deep_extend("force", default_opts, opts or {}))
            end
        end
    end
end

function Buffer:bufdo(cmd)
    vim.api.nvim_buf_call(self.bufnr, function()
        vim.api.nvim_command(cmd)
    end)
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
