---@class Proxy
local Proxy = {}

---Create a new Proxy
function Proxy.new(mt)
  return setmetatable({}, mt)
end

return Proxy
