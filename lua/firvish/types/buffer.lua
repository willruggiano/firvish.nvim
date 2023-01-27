---@class Buffer
---@field bufnr number the underlying buffer handle
---@field lines string[] the buffer lines
local Buffer = {}
Buffer.__index = Buffer

---Create a new buffer
---If name is provided, will rename the buffer via |nvim_buf_set_name|
---@param bufnr number the underlying buffer handle
---@param name? string used to rename the buffer
---@return Buffer
function Buffer:new(bufnr, name)
  local obj = setmetatable({
    bufnr = bufnr,
    lines = {},
  }, self)

  if name ~= nil then
    obj:rename(name)
  end

  return obj
end

---Whether a buffer is buflisted or not
---@return boolean
function Buffer:listed()
  return self:get_option "buflisted"
end

---Whether a buffer is |nvim_buf_is_loaded| or not
---@return boolean
function Buffer:loaded()
  return vim.api.nvim_buf_is_loaded(self.bufnr)
end

---Whether a buffer is |'modified'| or not
---@return boolean
function Buffer:modified()
  return self:get_option "modified"
end

---Whether a buffer is |nvim_buf_is_valid| or not
---@return boolean
function Buffer:valid()
  return vim.api.nvim_buf_is_valid(self.bufnr)
end

---Whether a buffer is visible or not
---That is, whether |bufwinnr()| ~= -1
---@return boolean
function Buffer:visible()
  return vim.fn.bufwinnr(self.bufnr) ~= -1
end

---Shorthand to |fnamemodify()| the |bufname()| of this buffer
---@return string
function Buffer:name(mods)
  return vim.fn.fnamemodify(vim.fn.bufname(self.bufnr), mods or ":p:~:.")
end

---Gets the buffer's |'filetype'|
---@return string
function Buffer:filetype()
  return self:get_option "filetype"
end

---Gets the buffer's |bufwinnr()|
---@return number
function Buffer:winnr()
  return vim.fn.bufwinnr(self.bufnr)
end

---Create a buffer-local auto-command
---Shorthand for |nvim_create_autocmd()| with the buffer option set to this buffer
function Buffer:create_autocmd(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_deep_extend("force", { buffer = self.bufnr }, opts))
end

---Create an autocmd, triggered on |BufDelete| and |BufWipeout|.
---@param f function the callback passed to |nvim_create_autocmd()|
function Buffer:on_buf_delete(f)
  self:create_autocmd({ "BufDelete", "BufWipeout" }, {
    callback = f,
  })
end

---Create a buffer-local user command
---Shorthand for |nvim_buf_create_user_command()| with bufnr preset
function Buffer:create_user_command(...)
  vim.api.nvim_buf_create_user_command(self.bufnr, ...)
end

---Shorthand for |nvim_buf_get_option()| with bufnr preset
function Buffer:get_option(key)
  return vim.api.nvim_buf_get_option(self.bufnr, key)
end

---Shorthand for |nvim_buf_set_option()| with bufnr preset
function Buffer:set_option(key, value)
  vim.api.nvim_buf_set_option(self.bufnr, key, value)
end

---Set multiple buffer-local options at once
function Buffer:set_options(options)
  for k, v in pairs(options) do
    self:set_option(k, v)
  end
end

---Checks whether this buffer points to the same bufnr as other
---@return boolean
function Buffer:is_same(other)
  if type(other) == "number" then
    return self.bufnr == other
  else
    return self.bufnr == other.bufnr
  end
end

---Shorthand for |getbufline()| with bufnr preset, but only returns a single line
function Buffer:line(linenr)
  return vim.fn.getbufline(self.bufnr, linenr)[1]
end

---Get a line-range from this buffer
---@param start number?
---@param end_ number?
---@param strict_indexing boolean?
---@return string[]
---@see vim.api.nvim_buf_get_lines
function Buffer:get_lines(start, end_, strict_indexing)
  start = (start == nil) and 0 or start
  end_ = (end_ == nil) and -1 or end_
  strict_indexing = (strict_indexing == nil) and true or strict_indexing
  ---@diagnostic disable-next-line: param-type-mismatch
  return vim.api.nvim_buf_get_lines(self.bufnr, start, end_, strict_indexing)
end

---Appends a line to this buffer
---@return Buffer
function Buffer:append(line)
  table.insert(self.lines, line)
  self:set_lines_()
  return self
end

---Shorthand for |nvim_buf_set_lines()|, overwriting the whole buffer contents
function Buffer:set_lines(lines)
  self.lines = lines
  self:set_lines_()
  return self
end

---@private
function Buffer:set_lines_()
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.lines)
end

---Filter a buffer's lines, like |:g|
---@param line1 number line range start
---@param line2 number line range end
---@param pattern string regex
---@param matching? boolean when true, remove lines matching the pattern, else remove lines NOT matching the pattern
---@param yank? boolean when true, uses the `:d` command, else uses the `:d_` command
---@usage [[
---buffer:filter_lines(0, -1, "lua", true) -- Only lines without "lua" in them
---@usage ]]
function Buffer:filter_lines(line1, line2, pattern, matching, yank)
  local bang = matching and "" or "!"
  local clobber = yank and "d" or "d_"
  if line1 == line2 then
    self:call("execute '%g" .. bang .. "/" .. pattern .. "/" .. clobber .. "'")
  else
    self:call("execute '" .. line1 .. "," .. line2 .. "g" .. bang .. "/" .. pattern .. "/" .. clobber .. "'")
  end
end

---Open this buffer
---@param how string? how to open the buffer, e.g. `:edit`, `:split`, `:vert pedit`, etc.
---@return Buffer
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
  end
  return self
end

---Shorthand for |vim.keymap.set()| with the buffer option preset
function Buffer:set_keymap(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_deep_extend("force", { buffer = self.bufnr }, opts))
end

local default_opts = { noremap = true, silent = true }

---Set mode mappings in this buffer
---Like set_keymap() but accepts a table where the lefthand side is the mode
---and the righthand side is table of mappings
---@usage [[
---
---local buffer = Buffer:new(...)
---buffer:set_keymaps {
---  n = {
---    -- <rhs> can be a function
---    ["<CR>"] = function()
---      ...
---    end,
---    -- or a table with a function as its first element
---    -- and a table as its second (to specify additional opts)
---    ["<C-y>"] = {
---      function()
---        ...
---      end,
---      { desc = "Do something with <C-y>" },
---    },
---  },
---}
---
---@usage ]]
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

---Execute an Ex command with this buffer as temporary current buffer
---@param cmd string anything suitable for |nvim_command()|
function Buffer:call(cmd)
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

---Shorthand for |nvim_buf_set_name()| with bufnr preset
function Buffer:rename(bufname)
  vim.api.nvim_buf_set_name(self.bufnr, bufname)
end

return Buffer
