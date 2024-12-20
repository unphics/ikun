---
---@brief 村庄
---

local SettlementType = require('Content/District/Settlements/SettlemengType')

---@class Village: Settlement
local Village = class.class "Village" : extends "Settlement" {
    ctor = function(Name) end
}
function Village:ctor(Name)
    class.Settlement.ctor(self, Name, SettlementType.Village)
end