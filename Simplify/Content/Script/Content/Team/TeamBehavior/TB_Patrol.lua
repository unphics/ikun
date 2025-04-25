
---
---@brief 巡逻行为
---@author zys
---@data Thu Apr 24 2025 00:12:44 GMT+0800 (中国标准时间)
---

local RoleConfig = require('Content/Role/Config/RoleConfig')
local BTType = require('Ikun.Module.AI.BT.BTType')

---@class TB_Patrol : TeamBehaviorBase
---@field OwnerTeam TeamClass
local TB_Patrol = class.class 'TB_Patrol' : extends 'TeamBehaviorBase' {
--[[public]]
    CalcAllMemberMoveTarget = function()end,
}
function TB_Patrol:Init()
    local AllMember = self.OwnerTeam.TeamMember:GetAllMember()
    for _, role in ipairs(AllMember) do
        ---@type RoleClass
        local Role = role
        local NewBTKey = RoleConfig[Role.RoleConfigId].BTCfg[BTType.Patrol]
        Role.BT.Blackboard:SetBBValue('BBNewBTKey', NewBTKey)        
    end
end
function TB_Patrol:CalcAllMemberMoveTarget()
    local Leader = self.OwnerTeam.TeamMember:GetLeader()
    local Loc = Leader.Avatar:GetNavAgentLocation()
    local bTeamSuccess, TeamMoveTargetLoc = class.NavMoveData.RandomNavPointInRadius(Leader.Avatar, Loc, 3000)
    for _, Role in ipairs(self.OwnerTeam.TeamMember.tbMember) do
        if Role == Leader then
            self.OwnerTeam.TeamMove:SetMemberMoveTarget(Role, TeamMoveTargetLoc)
        else
            local bSuccess, ResultLoc = class.NavMoveData.RandomNavPointInRadius(Leader.Avatar, TeamMoveTargetLoc, 500)
            self.OwnerTeam.TeamMove:SetMemberMoveTarget(Role, ResultLoc)
        end
    end
end
---@param EnemyTeam TeamClass
function TB_Patrol:OnEncounterEnemy(EnemyTeam)
    self.OwnerTeam.bFight = true

    self.OwnerTeam:NextState(class.new'TB_Fight'(self))
    self.OwnerTeam.CurTB:OnEncounterEnemy(EnemyTeam)
end

return TB_Patrol