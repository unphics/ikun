
---
---@brief   人类聚集地的基类
---@author  zys
---@data    Sat Dec 21 2024 00:51:53 GMT+0800 (中国标准时间)
---

---@class SettlementBaseClass
---@field SettlementActor SettlementCenter 此聚集地的Avatar
---@field _SettlementType SettlementType 聚集地类型:村庄/城市
---@field _SettlementName string 聚集地名字
---@field _tbLocation LocationClass[] 聚集地的成员地点, 如村子里的所有房子
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