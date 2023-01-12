local History = {}
History.__index = History

---@param filter Filter|function
function History:new(filter)
    filter = filter or function(_)
        return true
    end

    local oldfiles = {}
    for _, f in ipairs(vim.v.oldfiles) do
        if filter(f) then
            local name = vim.fn.fnamemodify(f, ":p:~:.")
            if name ~= "" then
                table.insert(oldfiles, name)
            end
        end
    end

    return setmetatable({
        oldfiles = oldfiles,
    }, self)
end

function History:lines()
    return self.oldfiles
end

return History
