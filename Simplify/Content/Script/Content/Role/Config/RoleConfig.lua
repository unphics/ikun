
local FightCareerDef = require('Content/Role/FightCareerDef')

local RoleConfig = {}

local row = function(tb)
    table.insert(RoleConfig, tb)
end

---@class RoleConfig
---@field FightCareerAssign FightCareerDef[]
RoleConfig[1] = {
    DisplayName = '鸽鸽',
    BelongKingdomCfgId = 1,
    InitBT = nil,
    Color = -1,
    SpecialClass = nil,
    FightCareerAssign = {FightCareerDef.MaleeDPS},
}

RoleConfig[2] = {
    DisplayName = '阿克巴鲁斯',
    Desc = '常见的',
    BelongKingdomCfgId = 2,
    InitBT = 'JungleMonsters_Burn_1',
    Color = -1,
    FightCareerAssign = {FightCareerDef.MaleeDPS, FightCareerDef.RangedDPS},
}

RoleConfig[3] = {
    DisplayName = '阿巴克',
    Desc = '见人就砍',
    SpecialClass = 'R_Lich_3',
    BelongKingdomCfgId = 3,
    InitBT = 'JungleMonsters_Burn_1',
    Color = 1,
}

RoleConfig[4] = {
    DisplayName = '鲁鲁修',
    BelongKingdomCfgId = 3,
    InitBT = 'JungleMonsters_Burn_1',
    Color = 1,
    FightCareerAssign = {FightCareerDef.MaleeDPS, FightCareerDef.RangedDPS},
}

RoleConfig[5] = {
    DisplayName = '阿卡拉',
    BelongKingdomCfgId = 1,
    InitBT = nil,
    Color = -1,
}

return RoleConfig