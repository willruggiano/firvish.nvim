local git = {}

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

return git
