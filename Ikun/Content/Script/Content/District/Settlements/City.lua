--[[
    @brief 城市
]]
    
local SettlementType = require('Content/District/Settlements/SettlemengType')

local City = class.class "City" : extends "Settlement" {
    ctor = function(Name) end
}
function City:ctor(Name)
    class.Settlement.ctor(self, Name, SettlementType.City)
end