local log = require "firvish.log"

local M = {}

local has_options, options = pcall(require, "options")
if not has_options then
    log.warning "options.nvim is not installed. See `:help firvish.txt` for disabled features."
end

if has_options then
    options.register_option {
        name = "alwayspreview",
        type_info = "boolean",
        description = "When set to true, the output of the running job will be shown in previewwindow.",
        default = false,
        source = "firvish",
        global = true,
    }
end

M.open_linedo_buffer = require "firvish.utils.open_linedo_buffer"
M.run_commands = require "firvish.utils.run_commands"
M.filter_lines = require "firvish.utils.filter_lines"
M.open_file_under_cursor = require "firvish.utils.open_file_under_cursor"
M.send_buf_lines_to_qf = require "firvish.utils.send_buf_lines_to_qf"

M.setup = function(opts)
    require("firvish.config").merge(opts or {})
    require "firvish.setup"
end

return M
