---@param line1 number
---@param line2 number
---@param matching boolean
---@param args string
return function(line1, line2, matching, args)
    local bang = ""
    if matching then
        bang = "!"
    end

    if line1 == line2 then
        vim.fn.execute("execute '%g" .. bang .. "/" .. args .. "/d'")
    else
        vim.fn.execute("execute '" .. line1 .. "," .. line2 .. "g" .. bang .. "/" .. args .. "/d'")
    end
end
