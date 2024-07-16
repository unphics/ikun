--[[
    @brief 人类聚集地
]]
class.class "Settlement" {
    Actor = nil,
    SettlementDef = {
        City    = 1, -- 城市
        Village = 2, -- 村庄
    },
    SettlementType = nil,
    Name = nil,
    ctor = function(self, Name, SettlementType)
        self.SettlementName = Name
        self.SettlementType = SettlementType
    end,
}