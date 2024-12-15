---
---@brief 村庄
---

local SettlementDef = require('Content/District/Settlements/SettlemengDef')

---@class Village: Settlement
local Village = class.class "Village" : extends "Settlement" {
    ctor = function(Name) end
}
function Village:ctor(Name)
    self.super.ctor(self, Name, SettlementDef.Village)
end