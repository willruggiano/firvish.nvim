---@mod firvish.nvim Introduction
---@brief [[
---
---Firvish is primarily a job control library.
---Additionally, it provides mechanisms which promote buffer-centric
---semantics as a means of working with job output.
---
---Practically speaking, you use firvish like so:
---1. You run a command via `firvish.start_job` and redirect its
---   output to a dedicated buffer.
---2. This dedicated buffer might have key mappings which are specific to
---   to the type of command you ran in (1). See |firvish-example-git|.
---3. You may choose to associate this job with a user command via
---   `firvish.create_user_command`. Notably, this api is designed to
---   make it easy to add |command-completion|.
---   NOTE: That this functionality is currently a work-in-progress and
---   not available on this branch.
---
---@brief ]]

local jobs = require "firvish.lib.jobs"

local firvish = {}

firvish.start_job = jobs.start_job

local function apply_keymaps(bufnr, keymaps)
  local default_opts = { buffer = bufnr, noremap = true, silent = true }
  for mode, mappings in pairs(keymaps) do
    for lhs, opts in pairs(mappings) do
      if opts then
        opts = vim.deepcopy(opts)
        local callback = assert(opts.callback, "must have a callback")
        opts.callback = nil
        vim.keymap.set(mode, lhs, callback, vim.tbl_extend("force", default_opts, opts))
      end
    end
  end
end

local function apply_options(bufnr, options)
  vim.api.nvim_buf_call(bufnr, function()
    for key, value in pairs(options) do
      vim.opt_local[key] = value
    end
  end)
end

firvish.extensions = setmetatable({}, {
  __index = function(_, key)
    error("[firvish] unknown extension: " .. key)
  end,
})

local Buffer = require "firvish.buffer2"
local Extension = {}
Extension.__index = Extension

function Extension.new(name, extension)
  local buffer = Buffer.new()
  local obj = {
    buffer = buffer,
    extension = extension,
    name = name,
  }

  if extension.bufname then
    buffer:set_name(extension.bufname)
  end

  apply_keymaps(buffer.bufnr, extension.keymaps or {})
  apply_options(buffer.bufnr, extension.options or {})

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    buffer = buffer.bufnr,
    callback = function()
      extension:on_buf_enter(buffer)
    end,
  })

  if buffer.opt.buftype == "acwrite" then
    vim.api.nvim_create_autocmd("BufWriteCmd", {
      buffer = buffer.bufnr,
      callback = function()
        extension:on_buf_write_cmd(buffer)
      end,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
      buffer = buffer.bufnr,
      callback = function()
        extension:on_buf_write_post(buffer)
      end,
    })
  end

  return setmetatable(obj, Extension)
end

function Extension:open()
  vim.cmd.buffer(self.buffer.bufnr)
end

function Extension:run(args)
  self:open()
  if self.extension.update then
    self.extension:update {
      buffer = self.buffer,
      flags = args.fargs[2],
      invert = args.bang,
    }
  end
end

local function complete(...)
  return vim.tbl_keys(firvish.extensions)
end

function firvish.setup(opts)
  vim.api.nvim_create_user_command("Firvish", function(args)
    local extension = firvish.extensions[args.fargs[1]]
    extension:run(args)
  end, { bang = true, complete = complete, desc = "Firvish", nargs = "+" })
end

function firvish.register_extension(name, extension)
  local obj = Extension.new(name, extension)
  firvish.extensions[name] = obj
  return extension
end

return firvish
