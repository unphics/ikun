
---
---@brief   人类聚集地的基类
---@author  zys
---@data    Sat Dec 21 2024 00:51:53 GMT+0800 (中国标准时间)
---

---@class SettlementBaseClass
---@field SettlementActor SettlementCenter 此聚集地的Avatar
---@field _SettlementType SettlementType
---@field _SettlementName string
---@field _tbLocation LocationClass[]
local SettlementBaseClass = class.class "SettlementBaseClass" {
    ctor = function(Name, SettlementType) end,
    SettlementActor = nil,
    _tbLocation = nil,
    _SettlementType = nil,
    _SettlementName = nil,
}

---@override
function SettlementBaseClass:ctor(Name, SettlementType)
    self._tbLocation = {}
    
    self._SettlementName = Name
    self._SettlementType = SettlementType
end

---@public 添加地点
---@param Location LocationClass
function SettlementBaseClass:AddLocation(Location)
    table.insert(self._tbLocation, Location)
end

return SettlementBaseClass