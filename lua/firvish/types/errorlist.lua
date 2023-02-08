---@class ErrorList
---@field action string
---@field context table
---@field efm string
---@field errorlist string
---@field title string
local ErrorList = {}
ErrorList.__index = ErrorList

---Construct a new errorlist (quickfix or loclist)
---@param errorlist string The type of errorlist to create, must be one of [quickfix, loclist].
---@param opts table See vim.fn.setqflist and vim.fn.setloclist
---@see vim.fn.setqflist
---@see vim.fn.setloclist
function ErrorList:new(errorlist, opts)
  assert(
    vim.tbl_contains({ "quickfix", "loclist" }, errorlist),
    "[firvish] 'errorlist' passed to start_job must be either a boolean, or the string 'quickfix' or 'loclist' to specify which errorlist to use."
  )
  local obj = setmetatable({
    action = opts.action or "r",
    context = opts.context or {},
    efm = opts.efm or vim.api.nvim_get_option "errorformat",
    errorlist = errorlist,
    title = opts.title,
  }, self)

  if opts.lines ~= nil then
    obj:set { lines = opts.lines }
  end

  return obj
end

---For the given buffer, send the specified range of lines to an errorlist (quickfix or loclist).
---@param errorlist string
---@param buffer Buffer
---@param line1 number
---@param line2 number
---@param opts table
function ErrorList:from_buf_lines(errorlist, buffer, line1, line2, opts)
  local errorformat = (function()
    local efm = {}
    for _, s in ipairs {
      vim.api.nvim_get_option "errorformat",
      buffer:get_option "errorformat",
    } do
      if s ~= nil and s ~= "" then
        table.insert(efm, s)
      end
    end
    return table.concat(efm, ",")
  end)()
  local error_list = ErrorList:new(errorlist, vim.tbl_deep_extend("force", { errorformat = errorformat }, opts))
  error_list:set {
    lines = buffer:lines(line1, line2, false),
  }
  return error_list
end

function ErrorList:set(opts)
  self:set_({}, self.action, {
    context = self.context,
    lines = opts.lines,
    efm = opts.efm or self.efm,
    title = self.title,
  })
end

local setters = {
  quickfix = vim.fn.setqflist,
  loclist = function(...)
    vim.fn.setloclist(0, ...)
  end,
}

function ErrorList:set_(...)
  setters[self.errorlist](...)
end

local openers = {
  quickfix = function(how)
    if type(how) == "string" then
      vim.cmd(how)
    elseif type(how) == "table" then
      vim.cmd.copen(how)
    else
      vim.cmd.copen { mods = { split = "botright" } }
    end
  end,
  loclist = function(how)
    if type(how) == "string" then
      vim.cmd(how)
    elseif type(how) == "table" then
      vim.cmd.lopen(how)
    else
      vim.cmd.lopen { mods = { split = "botright" } }
    end
  end,
}

function ErrorList:open(how)
  openers[self.errorlist](how)
end

local closers = {
  quickfix = vim.cmd.cclose,
  loclist = vim.cmd.lclose,
}

function ErrorList:close()
  closers[self.errorlist]()
end

return ErrorList
