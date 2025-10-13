
---
---@brief   城市
---@author  zys
---@data    Sat Dec 21 2024 00:51:53 GMT+0800 (中国标准时间)
---
    
local SettlementType = require('Content/District/Settlements/SettlemengType')

---@class CityClass: SettlementBaseClass
local CityClass = class.class "CityClass" : extends "SettlementBaseClass" {
    ctor = function() end
}

---@override
function CityClass:ctor(Name, Id)
    class.SettlementBaseClass.ctor(self, Name, SettlementType.City, Id)
end

return CityClass