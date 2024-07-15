--[[
    @brief 城市
]]
class.class "City" : extends "Settlement" {
    ctor = function(self, Name)
        self.super.ctor(self, Name, self.SettlementDef.City)
    end
}