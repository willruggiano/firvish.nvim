local jobs = require "firvish.lib.jobs"
local Extension = require "firvish.extension"

---@mod firvish
---@brief [[
---
---Firvish is a buffer-centric, mainly job-control oriented plugin library.
---The library provides abstractions to allow extension authors the ability
---to use generic, buffer-centric semantics on arbitrary buffer data by
---simply defining certain operations of their underlying data type.
---
---@brief ]]

---@tag :Firvish
---@brief [[
---Usage:
---
---  :Firvish[!] {extension} [args]
---
---  If [!] is given, the {extension} may use its "alternate behavior".
---  {extension} should be the name of an extension registered via
---    |firvish.register_extension|.
---  [args] are extension specific. See the relevant documentation for
---    the extension for details.
---
---@brief ]]

local firvish = {}

---Spawn {cmd} as a job. See |firvish-job-control|.
firvish.start_job = jobs.start_job

---Delete a job, stopping it if it is still running.
---See |firvish-job-control|.
firvish.delete_job = jobs.delete_job

---Get information about job as a list of dictionaries.
---See |firvish-job-control|.
firvish.getjobinfo = jobs.getjobinfo

---@package
firvish.extensions = setmetatable({}, {
  __index = function(_, key)
    error("[firvish] unknown extension: " .. key)
  end,
})

local function complete()
  return vim.tbl_keys(firvish.extensions)
end

---Create the |:Firvish| command.
---You can still run extensions programmatically, see |firvish-extensions|.
function firvish.setup()
  vim.api.nvim_create_user_command("Firvish", function(args)
    local extension = firvish.extensions[args.fargs[1]]
    extension(args)
  end, { bang = true, complete = complete, desc = "Firvish", nargs = "+" })
end

---Register a Firvish extension.
---This will make the extension available programmatically, see |firvish-extensions|.
---If combined with a call to |firvish.setup|, the extension can be
---invoked via the |:Firvish| user command.
function firvish.register_extension(name, impl)
  local extension = Extension.new(name, impl)
  firvish.extensions[name] = extension
  return extension
end

return firvish
