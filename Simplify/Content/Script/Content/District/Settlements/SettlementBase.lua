
---
---@brief   人类聚集地的基类
---@author  zys
---@data    Sat Dec 21 2024 00:51:53 GMT+0800 (中国标准时间)
---

---@class SettlementBaseClass
---@field SettlementActor SettlementCenter 此聚集地的Avatar
---@field SettlementType SettlementType
---@field Name string
local SettlementBaseClass = class.class "SettlementBaseClass" {
--[[public]]
    ctor = function(Name, SettlementType) end,
    SettlementActor = nil,
--[[private]]
    SettlementType = nil,
    Name = nil,
}

---@override
function SettlementBaseClass:ctor(Name, SettlementType)
    self.SettlementName = Name
    self.SettlementType = SettlementType
end

return SettlementBaseClass