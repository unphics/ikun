--[[
    @brief 村庄
]]
class.class "Village" : extends "Settlement" {
    ctor = function(self, Name)
        self.super.ctor(self, Name, self.SettlementDef.Village)
    end
}