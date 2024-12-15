---
---@brief 人类聚集地的基类
---

---@class Settlement
---@field Actor AActor 此聚集地的Avatar
---@field SettlementType SettlementDef
local Settlement = class.class "Settlement" {
--[[public]]
    ctor = function(Name, SettlementType) end,
    Actor = nil,
--[[private]]
    SettlementType = nil,
    Name = nil,
}
function Settlement:ctor(Name, SettlementType)
    self.SettlementName = Name
    self.SettlementType = SettlementType
end