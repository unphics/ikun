---
---@brief 组队
---@author zys
---@data Sun Mar 16 2025 23:04:24 GMT+0800 (中国标准时间)
---

---@class LTask_MakeTeam: LTask
---@field ConstMakeTeamJudgeRange number
local LTask_MakeTeam = class.class 'LTask_MakeTeam' : extends 'LTask' {
--[[public]]
    ctor = function()end,
--[[private]]
    ConstMakeTeamJudgeRange = nil,
}
function LTask_MakeTeam:ctor(NodeDispName)
    class.LTask.ctor(self, NodeDispName)
    self.ConstMakeTeamJudgeRange = 1500
end
function LTask_MakeTeam:OnInit()
    class.LTask.OnInit(self)
    local OwnerRole = self.Chr:GetRole()

    if not OwnerRole or OwnerRole.Team then
        return
    end

    -- 查找1000码以内的复合条件的单位, 再遍历查找从而进行递归查找出所有互相距离1000码以内的复合条件的单位
    local newTeam = TeamMgr:CreateNewTeam()
    OwnerRole.Team = newTeam

    OwnerRole.Team.TeamMember:AddMember(self.Chr:GetRole())
    self:FindNearbyRecurse(self.Chr, OwnerRole.Team)
    OwnerRole.Team:TeamInit()
    
    log.dev('zys dev recurse range find result: \n', self.Chr:GetRole().Team.TeamMember:PrintMember())
end
function LTask_MakeTeam:OnUpdate(DeltaTime)
    self:DoTerminate(true)
end
---@private
---@param RangeActor AActor
---@param Out_JoinTeam TeamClass
function LTask_MakeTeam:FindNearbyRecurse(RangeActor, Out_JoinTeam)
    local ActorArray = actor_util.find_actors_in_range(RangeActor, RangeActor:K2_GetActorLocation(),
        self.ConstMakeTeamJudgeRange, function(FilterActor)
        return FilterActor.GetRole
    end)
    for i = 1, ActorArray:Length() do
        local Actor = ActorArray:Get(i)
        if self:CheckCanJoinTeam(Actor) then
            Actor:GetRole().Team = Out_JoinTeam
            self:FindNearbyRecurse(Actor, Out_JoinTeam)
            Out_JoinTeam.TeamMember:AddMember(Actor:GetRole())
        end
    end
end
---@private
---@param Actor BP_ChrBase
---@return boolean
function LTask_MakeTeam:CheckCanJoinTeam(Actor)
    if Actor:GetRole().Team then
        return false
    end
    local OwnerRole = self.Chr:GetRole()
    if Actor.RoleComp.bCustomStartBT then
        return false
    end
    if OwnerRole:IsEnemy(Actor:GetRole()) then
        return false
    end
    return true
end