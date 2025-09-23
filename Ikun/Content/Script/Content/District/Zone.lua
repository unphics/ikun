
---
---@brief   大区/行省
---@author  zys
---@data    Sat Dec 21 2024 00:51:53 GMT+0800 (中国标准时间)
---@desc    大区有很多聚落(城市村庄等)
---

---@class ZoneClass
---@field ZoneName string
---@field _tbSettlement SettlementBaseClass[] 所有城市/村庄
local ZoneClass = class.class"ZoneClass"{
    ctor = function(Name) end,
    AddSettlement = function(Settlement) end,
    ZoneName = nil,
    _tbSettlement = nil,
}

---@override
function ZoneClass:ctor(Name)
    self.ZoneName = Name
    self._tbSettlement = {}
end

---@public
---@param Settlement SettlementBaseClass
function ZoneClass:AddSettlement(Settlement)
    table.insert(self._tbSettlement, Settlement)
end

return ZoneClass