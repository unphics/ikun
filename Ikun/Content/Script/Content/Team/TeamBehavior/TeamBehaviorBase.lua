
---
---@brief   团队行为的基类
---@author  zys
---@data    Thu Apr 24 2025 00:12:44 GMT+0800 (中国标准时间)
---

---@class TeamBehaviorBase
---@field OwnerTeam TeamClass
local TeamBehaviorBase = class.class 'TeamBehaviorBase' {
--[[public]]
    ctor = function()end,
    InitTB = function()end,
    UninitTB = function()end,
    OnEncounterEnemy = function()end,
--[[private]]
    OwnerTeam = nil,
}
function TeamBehaviorBase:ctor(Team)
    self.OwnerTeam = Team
end

---@public 初始化
function TeamBehaviorBase:InitTB()
end

---@public 反初始化
function TeamBehaviorBase:UninitTB()
end

---@public 当遭遇敌军时
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
---@param Role RoleBaseClass
function TeamBehaviorBase:CalcMemberMoveTarget(Role)
    return self.OwnerTeam.TeamMove:SetMemberMoveTarget(Role, Role.Avatar:K2_GetActorLocation(), false)
end
