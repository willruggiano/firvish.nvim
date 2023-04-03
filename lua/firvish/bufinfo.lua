local BufInfo = {}
BufInfo.__index = BufInfo

function BufInfo.new(bufinfo)
  return setmetatable(bufinfo, BufInfo)
end

return BufInfo
