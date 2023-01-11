---@class Filter
---@field predicate function
local Filter = {}
Filter.__index = Filter

---@param predicate function
function Filter:new(predicate)
    return setmetatable({
        predicate = predicate,
    }, self)
end

function Filter:__call(...)
    return self.predicate(...)
end

---@param other Filter
function Filter:__add(other)
    return Filter:new(function(...)
        return self.predicate(...) and other.predicate(...)
    end)
end

---@param other Filter
function Filter:__sub(other)
    return Filter:new(function(...)
        return self.predicate(...) and not other.predicate(...)
    end)
end

return Filter
