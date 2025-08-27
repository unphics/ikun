
local BTType = require('Ikun.Module/AI/BT/BTType')
local FightPosDef = require('Content/Role/FightPosDef')

local RoleConfig = {}

---@class RoleConfig
---@field FightPosAssign FightPosDef[]
---@field BTCfg table<BTType, string>
RoleConfig[1] = {
    DisplayName = '鸽鸽',
    BelongKingdomCfgId = 1,
    InitBT = nil,
    Color = -1,
    SpecialClass = nil,
    FightPosAssign = {},
    BTCfg = {},
}

---@type RoleConfig
RoleConfig[2] = {
    DisplayName = '阿克巴鲁斯',
    Desc = '常见的; 法师, 战士',
    BelongKingdomCfgId = 2,
    InitBT = 'Team_MakeTeam_1',
    Color = 1,
    FightPosAssign = {FightPosDef.Backline, FightPosDef.Frontline},
    BTCfg = {},
}
RoleConfig[2].BTCfg[BTType.Init] = 'Team_MakeTeam_1'
RoleConfig[2].BTCfg[BTType.Patrol] = 'Team_Patrol_Together_1'
-- RoleConfig[2].BTCfg[BTType.Fight] = 'Team_Fight_1'
RoleConfig[2].BTCfg[BTType.Fight] = 'Team_Fight_2'

RoleConfig[3] = {
    DisplayName = '阿巴克',
    Desc = '见人就砍; 法师, 战士',
    SpecialClass = 'R_Lich_3',
    BelongKingdomCfgId = 3,
    InitBT = 'JungleMonsters_Burn_1',
    Color = 1,
}

RoleConfig[4] = {
    DisplayName = '鲁鲁修',
    Desc = '法师, 战士',
    BelongKingdomCfgId = 3,
    InitBT = 'Team_MakeTeam_1',
    Color = 2,
    FightPosAssign = {FightPosDef.Backline, FightPosDef.Frontline},
    BTCfg = {},
}
RoleConfig[4].BTCfg[BTType.Init] = 'Team_MakeTeam_1'
RoleConfig[4].BTCfg[BTType.Patrol] = 'Team_Patrol_Together_1'
-- RoleConfig[4].BTCfg[BTType.Fight] = 'Team_Fight_1'
RoleConfig[4].BTCfg[BTType.Fight] = 'Team_Fight_2'

RoleConfig[5] = {
    DisplayName = '阿布噜布噜',
    BelongKingdomCfgId = 1,
    InitBT = nil,
    Color = -1,
}

return RoleConfig