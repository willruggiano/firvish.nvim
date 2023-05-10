local utils = require "firvish.utils"

local default_options = {
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
      operations_ = vim.tbl_extend("force", { create = false, delete = false, update = false }, opts.operations or {}),
      state_ = opts.state,
      type_ = type
    },
    vim.tbl_extend("force", { options = default_options }, opts.buffer or {})
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

function M:put_into(bufnr)
  self.items = self.generator_(self.state_)
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
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  for _, extmark in ipairs(extmarks) do
    vim.api.nvim_buf_set_extmark(bufnr, extmark.ns, extmark.line, extmark.col, extmark.opts)
  end
end

function M:get_from(bufnr)
  local items = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    table.insert(items, self.type_.from_line(line))
  end
  return items
end

function M:create_buf_()
  local bufnr = vim.api.nvim_create_buf(true, false)

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

  self:on({ "BufEnter", "BufWinEnter" }, {
    callback = function()
      vim.opt_local.buflisted = false
      self:put_into(bufnr)
      vim.opt_local.modified = false
    end,
  })

  self:on({ "BufWriteCmd" }, {
    callback = function()
      local previous = self.items
      local pending = self:get_from(bufnr)

      local operations = {
        create = {},
        delete = {},
        update = {},
      }

      if self.operations_.create == true then
        for _, td in ipairs(pending) do
          local found = false
          for _, tc in ipairs(previous) do
            if td:equals(tc) then
              found = true
              break
            end
          end
          if found then
            table.insert(operations.create, td)
          end
        end
      end

      if self.operations_.delete == true then
        for _, tc in ipairs(previous) do
          local found = false
          for _, td in ipairs(pending) do
            if tc:equals(td) then
              found = true
              break
            end
          end
          if found == false then
            table.insert(operations.delete, tc)
          end
        end
      end

      for _, t in ipairs(operations.create) do
        t:create(vim.v.cmdbang == 1)
      end

      for _, t in ipairs(operations.delete) do
        t:delete(vim.v.cmdbang == 1)
      end

      for _, t in ipairs(operations.update) do
        t:update(vim.v.cmdbang == 1)
      end

      self.items = pending
      vim.opt_local.modified = false
    end,
  })

  for _, e in ipairs(self.callbacks_) do
    vim.api.nvim_create_autocmd(
      e[1],
      vim.tbl_deep_extend("error", {
        buffer = bufnr,
      }, e[2])
    )
  end

  utils.apply_keymaps(bufnr, self.keymaps or {})
  utils.apply_options(bufnr, self.options or {})

  return bufnr
end

function M:on(event, opts)
  table.insert(self.callbacks_, { event, opts })
end

function M:open(opts)
  local bufnr = self:buffer()
  local how = opts.how or self.open_cmd
  local winnr = vim.fn.bufwinnr(bufnr)
  if winnr ~= -1 then
    vim.cmd.wincmd { args = { "w" }, count = winnr }
    vim.cmd.edit()
  else
    if how ~= nil and how ~= "edit" then
      if how == "pedit" then
        vim.cmd.pedit(vim.fn.bufname(bufnr))
        vim.cmd.wincmd { args = { "w" }, count = vim.fn.bufwinnr(bufnr) }
        return self
      else
        vim.cmd[how]()
      end
    end
    vim.cmd.buffer(bufnr)
  end
end

return M
