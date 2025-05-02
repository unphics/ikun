
---
---@brief 团队敌军信息, TeamClass的成员
---@author zys
---@data Sat Apr 12 2025 15:02:17 GMT+0800 (中国标准时间)
---

---@class TeamEnemyPerception
---@field Role RoleClass
---@field LastSeenTime number 最后一次更新时间
---@field LastSeenLoc FVector 最后一次更新的位置
---@field Confidence number 可信度
---@field Investigation number 侦查值(侦查程度)
---@field Visibility boolean 可见?
---@field TargetBy RoleClass|nil

---@class TeamEnemyClass
---@field tbEnemyRolePerception TeamEnemyPerception[]
---@field EnemyRoleMap table<number, TeamEnemyPerception>
---@field OwnerTeam TeamClass
---@field FireTarget RoleClass 集火目标
local TeamEnemyClass = class.class 'TeamEnemyClass' {
---[[public]]
    cotr = function()end,
    FireTarget = nil,
---[[private]]
    tbEnemyRolePerception = nil,
    EnemyRoleMap = nil,
    OwnerTeam = nil,
} 
function TeamEnemyClass:ctor(OwnerTeam)
    self.OwnerTeam = OwnerTeam
    self:ResetTeamEnemyData()
    if not self.OwnerTeam then
        log.error('TeamEnemyClass:ctor() Failed to index valid OwnerTeam')
    end
end
---@public 重置敌人
function TeamEnemyClass:ResetTeamEnemyData()
    self.EnemyRoleMap = {}
    self.tbEnemyRolePerception = {}
end
---@public 遭遇敌军; 第一次遭遇时, 根据敌军情况第一次评估敌军信息
---@param EnemyTeam TeamClass
function TeamEnemyClass:OnEncounterEnemy(EnemyTeam)
    ---@step 如该TeamLeader已添加, 则该Team已添加
    local EnemyLeaer = EnemyTeam.TeamMember:GetLeader()
    if self.EnemyRoleMap[EnemyLeaer.RoleInstId] then
        return
    end
    ---@step 存储敌军所有角色
    for i, Role in ipairs(EnemyTeam.TeamMember:GetAllMember()) do
        self:TryAddNewEnemyRole(Role)
    end 
end
---@private 尝试添加一个敌人角色
---@param EnemyRole RoleClass
function TeamEnemyClass:TryAddNewEnemyRole(EnemyRole)
    if self.EnemyRoleMap[EnemyRole.RoleInstId] then
        return
    end
    ---@type TeamEnemyPerception
    local RolePerception = {
        Role = EnemyRole,
        LastSeenLoc = EnemyRole.Avatar:K2_GetActorLocation(),
        LastSeenTime = 0,
        Visibility = true, ---@todo 隐身/遮挡/埋伏等藏起来的角色不可见
        Investigation = 1,
        Confidence = 1,
        TargetBy = nil,
    }
    self.EnemyRoleMap[EnemyRole.RoleInstId] = RolePerception
    table.insert(self.tbEnemyRolePerception, RolePerception)
end
---@public 根据远近排序(第一个最近)
function TeamEnemyClass:SortEnemyByDist()
    local OwnerLoc = self.OwnerTeam.TeamMember:GetLeader().Avatar:K2_GetActorLocation()
    table.sort(self.tbEnemyRolePerception, function(a, b)
        a.LastSeenLoc = a.Role.Avatar:K2_GetActorLocation()
        b.LastSeenLoc = b.Role.Avatar:K2_GetActorLocation()
        local Dist_A = UE.UKismetMathLibrary.Vector_Distance(a.LastSeenLoc, OwnerLoc)
        local Dist_B = UE.UKismetMathLibrary.Vector_Distance(b.LastSeenLoc, OwnerLoc)
        return Dist_A < Dist_B
    end)
end

return TeamEnemyClass