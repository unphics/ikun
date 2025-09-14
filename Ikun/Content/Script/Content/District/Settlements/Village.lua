
---
---@brief   村庄
---@author  zys
---@data    Sat Dec 21 2024 00:51:53 GMT+0800 (中国标准时间)
---

local SettlementType = require('Content/District/Settlements/SettlemengType')

---@class VillageClass: SettlementBaseClass
local VillageClass = class.class "VillageClass" : extends "SettlementBaseClass" {
    ctor = function(Name) end
}

---@override
function VillageClass:ctor(Name)
    class.SettlementBaseClass.ctor(self, Name, SettlementType.Village)
end