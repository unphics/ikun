
---
---@brief   移动行为, 偏应用
---@author  zys
---@data    Wed Jun 18 2025 00:02:19 GMT+0800 (中国标准时间)
---

---@class NavMoveBehav
---@field Chr BP_ChrBase
---@field Role RoleClass
---@field MaxStuckTime number
---@field QueryNavExtent FVector
---@field MoveToInfo MoveToInfo each
---@field NavMoveData NavMoveData each
---@field MoveStuckMonitor MoveStuckMonitor each
local NavMoveBehav = class.class 'NavMoveBehav' {
--[[public]]
    ctor = function()end,
    NewMoveToTask = function()end,
    TickMove = function()end,
--[[private]]
    HasReachedCurSegEnd = function()end,
    GetTaskTarget = function()end,
    GetTaskTargetLoc = function()end,
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
    self.Chr = rolelib.chr(Chr)
    self.Role = rolelib.role(Chr)
    self.MaxStuckTime = MaxStuckTime
    self.QueryNavExtent = UE.FVector(200, 200, 200)
end

---@class NavMoveBehavCallbackInfo
---@field This table
---@field OnNavMoveArrived fun()? 抵达时
---@field OnNavMoveLostTarget fun()? 失去目标时
---@field OnNavMoveCancelled fun()? 取消时
---@field OnNavMoveStuck fun()? 阻挡被时
---@field OnMoveTaskEnd fun()? 移动任务结束时

---@public 移动到一个新地方
---@param Target BP_ChrBase|FVector
---@param AcceptRadius number 可接受的半径
---@param CallbackInfo NavMoveBehavCallbackInfo
function NavMoveBehav:NewMoveToTask(Target, AcceptRadius, CallbackInfo)
    ---@class MoveToInfo
    local Info = {
        MoveTarget = Target, -- 主索引
        CacheTargetLoc = nil, ---@type FVector
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
        local moveToInfo = self:_ClearData()
        moveToInfo.bLostTarget = true
        moveToInfo.CallbackInfo.OnNavMoveLostTarget(moveToInfo.CallbackInfo.This)
        self:TaskEnd(moveToInfo)
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
        local moveToInfo = self:_ClearData()
        moveToInfo.bArrived = true
        moveToInfo.CallbackInfo.OnNavMoveArrived(moveToInfo.CallbackInfo.This)
        self:TaskEnd(moveToInfo)
        return
    end
    -- 如果目标不在导航网格内, 就在可接受的范围内尝试找一个最近的NavMesh点
    self.NavMoveData = class.new'NavMoveData'()
    if not self.NavMoveData:GenPathData(self.Chr, OwnerAgentLoc, TargetLoc) then
        local bTargetReachable = class.NavMoveData.ProjectPointToNavMesh(self.Chr, TargetLoc)
        if bTargetReachable then
            local bSelfMovable, NearNavPoint = class.NavMoveData.ProjectPointToNavMesh(self.Chr, OwnerAgentLoc, self.QueryNavExtent)
            if bSelfMovable then
                self.NavMoveData:GenPathData(self.Chr, NearNavPoint, TargetLoc, OwnerAgentLoc)
            end
            if not self.NavMoveData:IsValid() then
                local moveToInfo = self:_ClearData()
                moveToInfo.bStuck = true
                moveToInfo.CallbackInfo.OnNavMoveStuck(moveToInfo.CallbackInfo.This)
                self:TaskEnd(moveToInfo)
                return
            end
        end
    end
end

---@public
function NavMoveBehav:TickMove(DeltaTime)
    if not self.NavMoveData then
        return
    end
    -- 判断跑完了
    if self.NavMoveData:IsFinish() then    
        local moveToInfo = self:_ClearData()
        moveToInfo.bArrived = true
        moveToInfo.CallbackInfo.OnNavMoveArrived(moveToInfo.CallbackInfo.This)
        self:TaskEnd(moveToInfo)
        return
    end
    -- 判断被阻挡
    local OwnerAgentLoc = self.Chr:GetNavAgentLocation()
    if self.MoveStuckMonitor:TickCheck(DeltaTime, OwnerAgentLoc) then
        local moveToInfo = self:_ClearData()
        moveToInfo.bStuck = true
        moveToInfo.CallbackInfo.OnNavMoveStuck(moveToInfo.CallbackInfo.This)
        self:TaskEnd(moveToInfo)
        return
    end
    -- 寻路移动
    local Dir = self.NavMoveData:CalcChr2CurSegEndDir2D(self.Chr) ---@type FVector
    Dir:Normalize()
    self.Chr:AddMovementInput(Dir, 1, false)
    -- 抵达当前段目标则走下一段
    if self:HasReachedCurSegEnd(0.1) then
        self.NavMoveData:AdvanceSeg()
    end
end

---@private 已经抵达了当前段的目标
---@param RadiusCorr number 半径修正系数
function NavMoveBehav:HasReachedCurSegEnd(RadiusCorr)
    local OwnerAgentLoc = self.Chr:GetNavAgentLocation()
    local CurSegEndLoc = self.NavMoveData:GetCurSegEnd()
    local Radius = self.MoveToInfo.AcceptRadius * RadiusCorr
    local Distance = UE.UKismetMathLibrary.Vector_Distance(OwnerAgentLoc, CurSegEndLoc)
    if Distance < Radius then
        return true
    end
    return false
end

---@private 获取寻路目标
function NavMoveBehav:GetTaskTarget()
    return self.MoveToInfo and self.MoveToInfo.MoveTarget or nil
end

---@private 获取寻路目标的位置
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
function NavMoveBehav:TaskEnd(MoveToInfo)
    -- self:_ClearData()
    if MoveToInfo.CallbackInfo.OnMoveTaskEnd then
        MoveToInfo.CallbackInfo.OnMoveTaskEnd(MoveToInfo.CallbackInfo.This)
    end
end

---@public 取消移动
function NavMoveBehav:CancelMove()
    self.MoveToInfo = nil
    self.NavMoveData = nil
    self.MoveStuckMonitor = nil
    self:_ClearData()
end

---@private
---@return MoveToInfo
function NavMoveBehav:_ClearData()
    local moveToInfo = self.MoveToInfo
    self.MoveToInfo = nil
    self.NavMoveData = nil
    self.MoveStuckMonitor = nil
    return moveToInfo
end