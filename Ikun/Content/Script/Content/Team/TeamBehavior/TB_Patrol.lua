
---
---@brief   巡逻行为
---@author  zys
---@data    Thu Apr 24 2025 00:12:44 GMT+0800 (中国标准时间)
---@deprecated
---

local BTType = require('Ikun.Module.AI.BT.BTType')
local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class TB_Patrol : TeamBehaviorBase
---@field OwnerTeam TeamClass
local TB_Patrol = class.class 'TB_Patrol' : extends 'TeamBehaviorBase' {
--[[public]]
    CalcAllMemberMoveTarget = function()end,
    OnEncounterEnemy = function()end,
}
---@override
function TB_Patrol:InitTB()
    local AllMember = self.OwnerTeam.TeamMember:GetAllMember()
    for _, role in ipairs(AllMember) do
        ---@type RoleBaseClass
        local Role = role
        local NewBTKey = RoleMgr:GetRoleConfig(Role:GetRoleCfgId()).BTCfg[BTType.Patrol]
        Role.BT.Blackboard:SetBBValue(BBKeyDef.BBNewBTKey, NewBTKey)        
    end
end

function TB_Patrol:CalcAllMemberMoveTarget()
    local Leader = self.OwnerTeam.TeamMember:GetLeader()
    local Loc = Leader.Avatar:GetNavAgentLocation()
    local bTeamSuccess, TeamMoveTargetLoc = class.NavMoveData.RandomNavPointInRadius(Leader.Avatar, Loc, 3000)
    local allMember = self.OwnerTeam.TeamMember:GetAllMember()
    for _, Role in ipairs(allMember) do
        if Role == Leader then
            self.OwnerTeam.TeamMove:SetMemberMoveTarget(Role, TeamMoveTargetLoc, false)
        else
            local bSuccess, ResultLoc = class.NavMoveData.RandomNavPointInRadius(Leader.Avatar, TeamMoveTargetLoc, 500)
            self.OwnerTeam.TeamMove:SetMemberMoveTarget(Role, ResultLoc, false)
        end
    end
end

---@override 当巡逻中遭遇敌人时则转入战斗模式
---@param EnemyTeam TeamClass
function TB_Patrol:OnEncounterEnemy(EnemyTeam)
    local newTB = class.new'TB_Fight'(self.OwnerTeam) ---@type TeamBehaviorBase
    self.OwnerTeam:NextTeamState(newTB)
    newTB:OnEncounterEnemy(EnemyTeam)
end

return TB_Patrol