
---
---@brief   大区/行省
---@author  zys
---@data    Sat Dec 21 2024 00:51:53 GMT+0800 (中国标准时间)
---@desc    大区有很多聚落(城市村庄等)
---

---@class ZoneClass: MdBase
---@field ZoneName string
---@field tbSettlement SettlementBaseClass[] 所有城市/村庄
local ZoneClass = class.class"ZoneClass"{
--[public]
    ctor = function(Name) end,
    ZoneName = nil,
--[[private]]
    Init = function() end,
    AddSettlement = function(Settlement) end,
    tbSettlement = nil,
}

---@override
function ZoneClass:ctor(Name)
    self.ZoneName = Name
    self.tbSettlement = {}
end

---@public
---@param Settlement SettlementBaseClass
function ZoneClass:AddSettlement(Settlement)
    table.insert(self.tbSettlement, Settlement)
end

return ZoneClass