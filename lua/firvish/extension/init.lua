local config = require "firvish.config"
local filetype = require "firvish.filetype"

local extension = {}

function extension.register(name, opts)
  if opts.config then
    config.apply(opts.config, name)
  end

  if opts.filetype then
    filetype.add(name, opts.filetype)
  end
end

return extension
