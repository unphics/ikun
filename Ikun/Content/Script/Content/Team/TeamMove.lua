
---
---@brief 团队移动, 存储成员移动目标
---@author zys
---@data Sat Apr 19 2025 06:20:04 GMT+0800 (中国标准时间)
---@deprecated
---

---@class TeamMoveTarget
---@field MoveTarget FVector
---@field bArrived boolean

---@class TeamMoveClass
---@field OwnerTeam TeamClass
---@field mapMemberMoveTarget table<number, TeamMoveTarget>
local TeamMoveClass = class.class 'TeamMoveClass' {
--[[public]]
    ctor = function()end,
    GetMoveTarget = function()end,
    OnArrived = function()end,
    SetMemberMoveTarget = function()end,
    CalcTeamMemberCenter = function()end,
    IsAllMemberArrived = function()end,
--[[private]]
    OnAllMemberArrived = function()end,
    OwnerTeam = nil,
    mapMemberMoveTarget = nil,
}
function TeamMoveClass:ctor(Team)
    self.OwnerTeam = Team

end
---@public Role抵达后调用
function TeamMoveClass:OnArrived(Role)
    if not Role or not self.mapMemberMoveTarget or not self.mapMemberMoveTarget[Role:GetRoleId()] then
        return log.error('TeamMoveClass:OnArrived() 自身状态错误')
    end

    self.mapMemberMoveTarget[Role:GetRoleId()].bArrived = true

    if self:IsAllMemberArrived() then
        self:OnAllMemberArrived()
    end
end
---@public 是否所有成员都抵达了阶段性的移动目标
function TeamMoveClass:IsAllMemberArrived()
    for _, ele in pairs(self.mapMemberMoveTarget) do
        local MoveTarget = ele ---@type TeamMoveTarget
        if not MoveTarget.bArrived then
            return false
        end
    end
    return true
end
---@private 当所有人寻路完成后
function TeamMoveClass:OnAllMemberArrived()
    log.dev('TeamMoveClass:OnAllMemberArrived() 一个团队移动完成')
    self.mapMemberMoveTarget = nil
end
---@public 成员调用, 领取移动目标; 若无移动目标则让TB立即计算
function TeamMoveClass:GetMoveTarget(Role)
    if not self.mapMemberMoveTarget then
        if not self.OwnerTeam.CurTB.CalcAllMemberMoveTarget then
            log.error('TeamMoveClass:GetMoveTarget() TeamBehavior类型错误')
        else
            self.mapMemberMoveTarget = {}
            self.OwnerTeam.CurTB:CalcAllMemberMoveTarget()
        end
    end
    local MoveTargetData = self.mapMemberMoveTarget[Role:GetRoleId()]
    if not MoveTargetData then
        self.OwnerTeam.CurTB:CalcMemberMoveTarget(Role)
    end
    if not MoveTargetData or not MoveTargetData.MoveTarget then
        log.error('TeamMoveClass:GetMoveTarget() 未分配MoveTarget')
        return
    end
    return MoveTargetData.MoveTarget
end

---@public Team保存留给成员的移动目标
---@param MoveTarget FVector
---@param bForceMove boolean 强制移动
function TeamMoveClass:SetMemberMoveTarget(Role, MoveTarget, bForceMove)
    if not self.mapMemberMoveTarget then
        self.mapMemberMoveTarget = {}
    end
    ---@type TeamMoveTarget
    local tb = {MoveTarget = MoveTarget, bArrived = false, bForceMove = bForceMove}
    self.mapMemberMoveTarget[Role:GetRoleId()] = tb
    return tb
end

---@public [Pure] [Calc] 鲁棒中心估计(质心+离群排除)
---@return FVector
function TeamMoveClass:CalcTeamMemberCenter(ArrRole)
    local AllMember = ArrRole -- self.OwnerTeam.TeamMember:GetAllMember()
    if #AllMember == 0 then
        return
    end
    if #AllMember == 1 then
        local Loc = AllMember[1].Avatar:K2_GetActorLocation()
        return Loc
    end
    ---@step 1.计算初始中心(普通质心)
    local SumLoc = UE.FVector()
    for _, role in ipairs(AllMember) do
        local roleLoc = role.Avatar:K2_GetActorLocation()
        SumLoc = UE.UKismetMathLibrary.Add_VectorVector(SumLoc, roleLoc)
    end
    local CenterLoc = UE.UKismetMathLibrary.Divide_VectorInt(SumLoc, #AllMember)
    ---@step 2.计算所有点到中心的距离
    local Distances = {}
    local TotalDist = 0
    for i, role in ipairs(AllMember) do
        local Delta = UE.UKismetMathLibrary.Subtract_VectorVector(role.Avatar:K2_GetActorLocation(), CenterLoc)
        local Dist = math.sqrt(Delta.X * Delta.X + Delta.Y * Delta.Y + Delta.Z * Delta.Z)
        Distances[i] = Dist
        TotalDist = TotalDist + Dist
    end
    local AvgDist = TotalDist / #AllMember
    ---@step 3.排除离群点(距离超过平均值2倍的)
    local Kept = {} -- 排除离群点后的Role[]
    for i, role in ipairs(AllMember) do
        if Distances[i] <= AvgDist * 2 then
            table.insert(Kept, role)
        end
    end
    ---@step 4.对剩下的点重新计算中心
    local KeptLen = #Kept
    if KeptLen == 0 then
        return CenterLoc -- 全部被提出就返回初始中心
    end
    local KSumLoc = UE.FVector()
    for _, role in ipairs(Kept) do
        KSumLoc = KSumLoc + role.Avatar:K2_GetActorLocation()
    end
    local KAvg = UE.UKismetMathLibrary.Divide_VectorInt(KSumLoc, KeptLen)
    return KAvg
end

return TeamMoveClass