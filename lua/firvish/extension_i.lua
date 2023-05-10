local utils = require "firvish.utils"

local default_options = {
  bufhidden = "wipe",
  buflisted = false,
  buftype = "acwrite",
  swapfile = false,
}

local M = {}
M.__index = M

function M.new(type, opts)
  -- stylua: ignore start
  local obj = vim.tbl_extend(
    "error",
    {
      callbacks_ = {},
      generator_ = opts.generator,
      namespace_ = opts.namespace,
      state_ = opts.state,
      type_ = type
    },
    vim.tbl_extend("force", default_options, opts.buffer or {})
  )
  -- stylua: ignore end
  return setmetatable(obj, M)
end

function M:buffer()
  if self.bufnr_ == nil then
    self.bufnr_ = self:create_buf_()
  end
  return self.bufnr_
end

function M:create_buf_()
  local bufnr = vim.api.nvim_create_buf(true, true)

  if self.name ~= nil then
    vim.api.nvim_buf_set_name(bufnr, self.name)
  end

  for name, value in pairs(self.options or {}) do
    vim.api.nvim_buf_set_option(bufnr, name, value)
  end

  for mode, mappings in pairs(self.keymap or {}) do
    for lhs, opts in pairs(mappings) do
      vim.keymap.set(mode, lhs, opts.callback, opts)
    end
  end

  self:on({ "BufEnter", "BufWinEnter" }, function()
    self.items = self.generator_(self.state_, self.items)
    local lines = {}
    local extmarks = {}
    for i, item in ipairs(self.items) do
      local line, virt_text = item:to_line(self.state_, self.items)
      table.insert(lines, line)
      table.insert(extmarks, virt_text and {
        ns = self.namespace_,
        line = i - 1,
        col = -1,
        opts = {
          virt_text = {
            virt_text,
          },
          virt_text_pos = "right_align",
        },
      } or false)
    end
    vim.api.nvim_buf_set_lines(self.bufnr_, 0, -1, false, lines)
    for _, extmark in ipairs(extmarks) do
      vim.api.nvim_buf_set_extmark(self.bufnr_, extmark.ns, extmark.line, extmark.col, extmark.opts)
    end
  end)

  for _, e in ipairs(self.callbacks_) do
    vim.api.nvim_create_autocmd(e[1], {
      buffer = bufnr,
      callback = e[2],
    })
  end

  utils.apply_keymaps(bufnr, self.keymaps or {})
  utils.apply_options(bufnr, self.options or {})

  return bufnr
end

function M:on(event, callback)
  table.insert(self.callbacks_, { event, callback })
end

function M:open(opts)
  local bufnr = self:buffer()
  local how = opts.how
  local winnr = vim.fn.bufwinnr(bufnr)
  if winnr ~= -1 then
    vim.cmd.wincmd { args = { "w" }, count = winnr }
    vim.cmd.edit()
  else
    if how ~= nil and how ~= "edit" then
      if how == "pedit" then
        vim.cmd.pedit(self:name())
        vim.cmd.wincmd { args = { "w" }, count = self:winnr() }
        return self
      else
        vim.cmd[how]()
      end
    end
    vim.cmd.buffer(bufnr)
  end
end

return M
