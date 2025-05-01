
---
---@brief 团队移动, 存储成员移动目标
---@author zys
---@data Sat Apr 19 2025 06:20:04 GMT+0800 (中国标准时间)
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
--[[private]]
    OnAllMemberArrived = function()end,
    OwnerTeam = nil,
    mapMemberMoveTarget = nil,
}
function TeamMoveClass:ctor(Team)
    self.OwnerTeam = Team

end
function TeamMoveClass:OnArrived(Role)
    if not Role or not self.mapMemberMoveTarget then
        return log.error('TeamMoveClass:OnArrived() 自身状态错误')
    end

    self.mapMemberMoveTarget[Role.RoleInstId].bArrived = true

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
    local MoveTarget = self.mapMemberMoveTarget[Role.RoleInstId].MoveTarget
    if not MoveTarget then
        log.error('TeamMoveClass:GetMoveTarget() 未分配MoveTarget')
    end
    return MoveTarget
end
---@public Team保存留给成员的移动目标
---@param MoveTarget FVector
function TeamMoveClass:SetMemberMoveTarget(Role, MoveTarget)
    ---@type TeamMoveTarget
    local tb = {MoveTarget = MoveTarget, bArrived = false}
    self.mapMemberMoveTarget[Role.RoleInstId] = tb
    return tb
end

return TeamMoveClass