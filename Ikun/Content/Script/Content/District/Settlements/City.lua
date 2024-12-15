--[[
    @brief 城市
]]
    
local SettlementDef = require('Content/District/Settlements/SettlemengDef')

local City = class.class "City" : extends "Settlement" {
    ctor = function(Name) end
}
function City:ctor(Name)
    self.super.ctor(self, Name, SettlementDef.City)
end