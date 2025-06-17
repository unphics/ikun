
---
---@brief   移动行为
---@author  zys
---@data    Wed Jun 18 2025 00:02:19 GMT+0800 (中国标准时间)
---

---@class NavMoveBehav : MdBase
---@field Chr BP_ChrBase
---@field Role RoleClass
---@field MaxStuckTime number
---@field QueryNavExtent FVector
---@field MoveToInfo MoveToInfo
---@field MoveStuckMonitor MoveStuckMonitor
local NavMoveBehav = class.class 'NavMoveBehav' : extends 'MdBase' {
--[[public]]
    ctor = function()end,
    NewMoveTo = function()end,
    GetTaskTarget = function()end,
    GetTaskTargetLoc = function()end,
--[[private]]
    TaskEnd = function()end,
    Chr = nil,
    Role = nil,
    MaxStuckTime = nil,
    QueryNavExtent = nil,
    MoveToInfo = nil,
}
---@override
---@param Chr BP_ChrBase|RoleClass
function NavMoveBehav:ctor(Chr, MaxStuckTime)
    self.Chr = log.chr(Chr)
    self.Role = log.role(Chr)
    self.MaxStuckTime = MaxStuckTime
    self.QueryNavExtent = UE.FVector(200, 200, 200)
end

---@class NavMoveBehavCallbackInfo
---@field This table
---@field OnNavMoveArrived function 抵达时
---@field OnNavMoveLostTarget function 失去目标时
---@field OnNavMoveCancelled function 取消时
---@field OnNavMoveStuck function 阻挡被时

---@public 移动到一个新地方
---@param Target BP_ChrBase|FVector
---@param AcceptRadius number 可接受的半径
---@param CallbackInfo NavMoveBehavCallbackInfo
function NavMoveBehav:NewMoveToTask(Target, AcceptRadius, CallbackInfo)
    ---@class MoveToInfo
    local Info = {
        MoveTarget = Target, -- 主索引
        CacheTargetLoc = UE.FVector(),
        bArrived = false,
        bLostTarget = false,
        bCancelled = false,
        bStuck = false,
        CallbackInfo = CallbackInfo,
        AcceptRadius = AcceptRadius
    }
    self.MoveToInfo = Info
    -- 检查目标有效
    local TargetLoc = self:GetTaskTargetLoc()
    if not TargetLoc then
        self.MoveToInfo.CallbackInfo.OnNavMoveLostTarget(self.MoveToInfo.CallbackInfo.This)
        return
    end
    -- 检查是否已经可以判断抵达
    if self:GetTaskTarget().IsA then
        if self:GetTaskTarget():GetMovementComponent() then
            self.MoveToInfo.AcceptRadius = self.MoveToInfo.AcceptRadius + self:GetTaskTarget():GetMovementComponent().NavAgentProps.AgentRadius
        end
    end
    local OwnerAgentLoc = self.Chr:GetNavAgentLocation()
    self.MoveStuckMonitor = class.new'MoveStuckMonitor'(self.MaxStuckTime, OwnerAgentLoc)
    local Distance = UE.UKismetMathLibrary.Vector_Distance(OwnerAgentLoc, TargetLoc)
    if Distance < self.MoveToInfo.AcceptRadius then
        self.MoveToInfo.CallbackInfo.OnNavMoveArrived(self.MoveToInfo.CallbackInfo.This)
        return
    end
    -- 
end

---@public 获取寻路目标
function NavMoveBehav:GetTaskTarget()
    return self.MoveToInfo and self.MoveToInfo.MoveTarget or nil
end

---@public 获取寻路目标的位置
function NavMoveBehav:GetTaskTargetLoc()
    if not self.MoveToInfo then
        return
    end
    if self:GetTaskTarget().IsA then
        local bSuccess, FixedLoc = class.NavMoveData.ProjectPointToNavMesh(self.Chr, self:GetTaskTarget(), self.QueryNavExtent)
        if bSuccess then
            return FixedLoc
        else
            log.error('tmp')
        end
    elseif self.MoveToInfo.CacheTargetLoc then
        return self.MoveToInfo.CacheTargetLoc
    else
        local bSuccess, FixedLoc = class.NavMoveData.ProjectPointToNavMesh(self.Chr, self:GetTaskTarget(), self.QueryNavExtent)
        if bSuccess then
            self.MoveToInfo.CacheTargetLoc = FixedLoc
            return FixedLoc
        else
            log.error('tmp')
        end
    end
end

---@private 移动任务结束, 清理数据
function NavMoveBehav:TaskEnd()
    self.MoveToInfo = nil
end