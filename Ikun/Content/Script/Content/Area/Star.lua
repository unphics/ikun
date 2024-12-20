---
---@brief 星球
---

require("Content.District.DistrictMgr")

---@class Star
---@field DistrictMgr DistrictMgr
local Star = class.class "Star": extends 'MdBase' {
--[[public]]
    ctor = function(Name) end,
    Tick = function()end,
--[private]
    Name = nil,
    DistrictMgr = nil,
}
function Star:ctor(Name)
    self.StarName = Name
    self.DistrictMgr = class.new "DistrictMgr" (self.StarName)
end
function Star:Tick(DeltaTime)
    self.DistrictMgr:Tick(DeltaTime)
end