local jobs = require "firvish.lib.jobs"

vim.api.nvim_create_user_command("LemmyHelp", function()
  jobs.start_job {
    command = "nix",
    args = { "run", ".#generate-vimdoc" },
    bopen = false,
    on_exit = function()
      vim.cmd.edit "./doc/REPLACE_ME-firvish.txt"
    end,
  }
end, {})
