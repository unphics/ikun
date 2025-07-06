
---
---@brief 团队行为的基类
---@author
---@data Thu Apr 24 2025 00:12:44 GMT+0800 (中国标准时间)
---

---@class TeamBehaviorBase: MdBase
---@field OwnerTeam TeamClass
local TeamBehaviorBase = class.class 'TeamBehaviorBase' : extends 'MdBase' {
--[[public]]
    ctor = function()end,
--[[private]]
    OwnerTeam = nil,
}
function TeamBehaviorBase:ctor(Team)
    self.OwnerTeam = Team
end
---@public
---@param EnemyTeam TeamClass
function TeamBehaviorBase:OnEncounterEnemy(EnemyTeam)
end

function TeamBehaviorBase:CalcAllMemberMoveTarget()
    local allMember = self.OwnerTeam.TeamMember:GetAllMember()
    for _, Role in ipairs(allMember) do
        self:CalcMemberMoveTarget(Role)
    end
end

---@public
---@param Role RoleClass
function TeamBehaviorBase:CalcMemberMoveTarget(Role)
    return self.OwnerTeam.TeamMove:SetMemberMoveTarget(Role, Role.Avatar:K2_GetActorLocation(), false)
end
