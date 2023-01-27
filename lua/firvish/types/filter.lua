---@mod firvish.filter
---@tag firvish-filters
---@brief [[
---Filters can be used in several contexts to modify what data is being returned to you (e.g. from
---an API call) or what is being shown in a Firvish buffer (e.g. the |firvish-buffers| buffer).
---
---Filters can be composed using `+` and `-`.
---
--->
---local is_listed = Filter:new(function(bufnr)
---  return vim.fn.buflisted(bufnr)
---end)
---
---local is_modified = Filter:new(function(bufnr)
---  return vim.bo[bufnr].modified
---end)
---
---local is_listed_and_modified = is_listed + is_modified
---local is_listed_not_modified = is_listed - is_modified
---
---local bufnr_listed_modified = 42
---local bufnr_listed_not_modified = 13
---assert(is_listed_and_modified(bufnr_listed_modified) == true)
---assert(is_listed_not_modified(bufnr_listed_not_modified) == true)
---<
---@brief ]]
---@see firvish-buffers

---@package
---@class Filter
---@field predicate function
local Filter = {}
Filter.__index = Filter

---Constructs a new Filter from the given predicate function
---@param predicate function
---@return Filter
---@usage [[
---local filter = Filter:new(function(...)
---  return true
---end)
---@usage ]]
function Filter:new(predicate)
  return setmetatable({
    predicate = predicate,
  }, self)
end

---@package
---@return boolean
function Filter:__call(...)
  return self.predicate(...)
end

---@package
---@param other Filter
---@return Filter
function Filter:__add(other)
  return Filter:new(function(...)
    return self.predicate(...) and other.predicate(...)
  end)
end

---@package
---@param other Filter
---@return Filter
function Filter:__sub(other)
  return Filter:new(function(...)
    return self.predicate(...) and not other.predicate(...)
  end)
end

return Filter
