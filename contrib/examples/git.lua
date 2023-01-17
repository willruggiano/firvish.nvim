local git = {}

local cmd = require "firvish.lib.cmd"
local jobs = require "firvish.lib.jobs"

---Streams the output of `git ls-files` to a dedicated buffer.
---You can then use normal |firvish-dir| mappings to manipulate files in your git repository.
function git.ls()
    jobs.start_job {
        command = "git",
        args = { "ls-files" },
        filetype = "firvish-dir",
        title = "git ls-files",
        bopen = {
            headers = false,
        },
    }
end

function git.create_user_command()
    cmd.create_from_spec(":LsFiles[!] [path:path]", {
        desc = "Open a buffer with the output of git ls-files",
    })
end

return git
