---
---@brief 星球
---

require("Content.District.DistrictMgr")

---@class Star: MdBase
---@field DistrictMgr DistrictMgr
---@field Name string 星球的名字
---@field StarId number 星球的Id
local Star = class.class "Star": extends 'MdBase' {
--[[public]]
    ctor = function()end,
    Init = function()end,
    Tick = function()end,
    StarId = nil,
    Name = nil,
--[private]
    DistrictMgr = nil,
}
function Star:ctor(Id, Name)
    self.StarId = Id
    self.StarName = Name
    self.DistrictMgr = class.new "DistrictMgr" (self)
end
function Star:Init()
end
function Star:Tick(DeltaTime)
    self.DistrictMgr:Tick(DeltaTime)
end