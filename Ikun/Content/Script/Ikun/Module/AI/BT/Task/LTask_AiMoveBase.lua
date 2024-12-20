
---@class LTask_AiMoveBase: LTask
---@field NavTarget AActor | FVector
---@field StaticAcceptRadius number
---@field StaticMaxStuckTime number
---@field StaticMaxDirGap number
---@field CachedFinalTargetLoc number
---@field AccectableRadius number
local LTask_AiMoveBase = class.class 'LTask_AiMoveBase' : extends 'LTask' {
    ctor = function()end,
    GetTargetLoc = function()end,
    GetNavTarget = function()end,
    OnMoveStucked = function()end,
    StaticQueryNavExtent = nil,
    StaticAcceptRadius = nil,
    StaticMaxStuckTime = nil,
    StaticMaxDirGap = nil,
    CachedFinalTargetLoc = nil,
    AccectableRadius = nil,
}
function LTask_AiMoveBase:ctor(TaskName, AcceptRadius, MaxDirGap, MaxStuckTime, QueryNavExtent)
    class.LTask.ctor(self, TaskName)

    self.StaticAcceptRadius = AcceptRadius
    self.StaticMaxDirGap = MaxDirGap
    self.StaticMaxStuckTime = MaxStuckTime
    self.StaticQueryNavExtent = QueryNavExtent
end
function LTask_AiMoveBase:OnInit()
    class.LTask.OnInit(self)
    self.CachedFinalTargetLoc = nil

    local TargetLoc = self:GetTargetLoc()
    if not TargetLoc then
        self:DoTerminate(false)
        return log.error('AiMoveBase: Invalid Target!')
    end

    self.AccectableRadius = self:GetAccectableRadius()
    local AgentLoc = self.Chr:GetNavAgentLocation()
    local Distance = UE.UKismetMathLibrary.Vector_Distance(AgentLoc, TargetLoc)
    if Distance < self.AccectableRadius then
        self:DoTerminate(true)
        return log.warn('AiMoveBase: Already Reached Target Initially !')
    end

    if not self:MakeNavPathSegs(AgentLoc, TargetLoc) then
        local bTargetReachable = self:ProjectPointToNav(TargetLoc)
        ---@todo 对于复杂行为的Npc,可以尝试从目标身上获取一个可达点
        if bTargetReachable then
            local bSelfMovable, NearNavPoint = self:ProjectPointToNav(AgentLoc, self.StaticQueryNavExtent)
            if bSelfMovable then
                self:MakeNavPathSegs(NearNavPoint, TargetLoc, AgentLoc) ---@todo 待验证此处First
            end
        end
        if not next(self.tbNavPoint) then
            self:OnMoveStucked()
            return log.error('AiMoveBase: Failed to get valid seg !')
        end
    end

    if (2 == #self.tbNavPoint) and self:HasReachedCurTarget(1) then
        if Distance < self.AccectableRadius * 2 then
            self:DoTerminate(true)
            return log.warn('AiMoveBase: Already Reached Target Nearby Initially !')
        else
            return self:OnMoveStucked()
        end
    end

    if not self:CheckDirGap() then
        self:DoTerminate(false)
        return log.error('AiMoveBase: Need to Face to Target !')
    end

    self.CachedFinalTargetLoc = TargetLoc
    self.UpdateTimeCount = -1
    self.DetectMoveStuckDuration = 0
end
function LTask_AiMoveBase:OnUpdate(DeltaTime)
    if self.SegIdx > #self.tbNavPoint then
        self:DoTerminate(true)
        return log.log('AiMoveBase: Ai Move Reached !')
    end
    local AgentLoc = self.Chr:GetNavAgentLocation()
    ---@todo About First Point

    self.DetectMoveStuckDuration = self.DetectMoveStuckDuration + DeltaTime
    if UE.UKismetMathLibrary.EqualEqual_VectorVector(self.MoveStuckLoc, AgentLoc, 10) then
        if self.DetectMoveStuckDuration > self.StaticMaxStuckTime then
            self:OnMoveStucked()
            return log.error('AiMoveBase: Stucked On Moveing !')
        end
    else
        self.DetectMoveStuckDuration = 0
        self.MoveStuckLoc = AgentLoc
    end
    local CurSegEndLoc = self.tbNavPoint[self.SegIdx]
    local Dir = CurSegEndLoc - AgentLoc
    Dir.Z = 0
    Dir:Normalize()
    self.Chr:AddMovementInput(Dir)
    if (self.SegIdx == #self.tbNavPoint) and self:HasReachedCurTarget(1) then
        local Distance = UE.UKismetMathLibrary.Vector_Distance(AgentLoc, self:GetTargetLoc())
        if Distance < self.AccectableRadius * 2 then
            self:DoTerminate(true)
            return log.warn('AiMoveBase: Already Reached Target Nearby Initially !')
        else
            return self:OnMoveStucked()
        end
    else
        if self:HasReachedCurTarget(0.05) then
            self.SegIdx = self.SegIdx + 1
        end
    end
end
function LTask_AiMoveBase:HasReachedCurTarget(RadiusCorr)
    local AgentLoc = self.Chr:GetNavAgentLocation()
    local CurSegEndLoc, CurSegDir = self.tbNavPoint[self.SegIdx], self.tbNavDir[self.SegIdx]
    -- if #self.tbNavPoint < 10 then
    --     local ToTargetDir = CurSegEndLoc - AgentLoc
    --     local SegDot = ToTargetDir:Dot(CurSegDir)
    --     if SegDot > 0 then
    --         return true
    --     end
    -- end
    local Radius = self.AccectableRadius * RadiusCorr
    local Distance = UE.UKismetMathLibrary.Vector_Distance(AgentLoc, CurSegEndLoc)
    if Distance < Radius then
        return true
    end
    return false
end
function LTask_AiMoveBase:MakeNavPathSegs(Start, End, First)
    local NavPathPoints = UE.UNavigationSystemV1.FindPathToLocationSynchronously(self.Chr, Start, End, self.Chr, nil)
    self.OutNavIdx = 0
    self.SegIdx = 2
    self.tbNavPoint = {}
    self.tbNavDir = {}
    if NavPathPoints.PathPoints:Length() > 1 then
        if First then
            table.insert(self.tbNavPoint, First)
            self.OutNavIdx = 2
        end
        for i = 1, NavPathPoints.PathPoints:Length() do
            local Point = NavPathPoints.PathPoints:Get(i)
            if #self.tbNavPoint > 0 then
                local Dir = Point - self.tbNavPoint[#self.tbNavPoint]
                Dir.Z = 0
                Dir:Normalize()
                table.insert(self.tbNavDir, Dir)
            end
            table.insert(self.tbNavPoint, Point)
        end
        table.insert(self.tbNavDir, self.tbNavDir[#self.tbNavDir])
    end
    -- for _, vec in ipairs(self.tbNavPoint) do
    --     UE.UKismetSystemLibrary.DrawDebugSphere(self.Chr, vec, 40, 12, UE.FLinearColor(1, 0, 0), 1, 2)
    -- end
    return next(self.tbNavPoint) and true or false
end
function LTask_AiMoveBase:GetTargetLoc()
    if not self:GetNavTarget() then
        return log.error('AiMoveBase: Invalid Nav Target !')
    end
    if self:GetNavTarget().IsA then
        local bProjectTarget, FixedLoc = self:ProjectPointToNav(self:GetNavTarget():K2_GetActorLocation(), self.StaticQueryNavExtent)
        if bProjectTarget then
            return FixedLoc
        else
            return log.error('AiMoveBase: Can not Project Actor To Nav Mesh !')
        end
    else
        if self.CachedFinalTargetLoc then
            return self.CachedFinalTargetLoc
        else
            local bProjectTarget, FixedLoc = self:ProjectPointToNav(self:GetNavTarget(), self.StaticQueryNavExtent)
            if bProjectTarget then
                self.CachedFinalTargetLoc = FixedLoc
                return FixedLoc
            else
                return log.error('AiMoveBase: Can not Project Target To Nav Mesh !')
            end    
        end
    end
end
function LTask_AiMoveBase:CheckDirGap()
    local AgentLoc = self.Chr:GetNavAgentLocation()
    local CurSegEndLoc = self.tbNavPoint[self.SegIdx]
    local ToCurSegEndDir = CurSegEndLoc - AgentLoc
    local ToCurSegEndRot = UE.UKismetMathLibrary.Conv_VectorToRotator(ToCurSegEndDir)
    local DeltaRot = UE.UKismetMathLibrary.NormalizedDeltaRotator(ToCurSegEndRot, self.Chr:K2_GetActorRotation())
    if math.abs(DeltaRot.Yaw) > self.StaticMaxDirGap then
        self:DoTerminate(false)
        log.error('AiMoveBase: Dir Gap Too Large !')
        return false
    end
    return true
end
function LTask_AiMoveBase:ProjectPointToNav(Point, QueryEvent)
    local ProjectedPoint = UE.FVector(0, 0, 0)
    QueryEvent = QueryEvent or UE.FVector(0, 0, 0)
    local bSuccess = UE.UNavigationSystemV1.K2_ProjectPointToNavigation(self.Chr, Point, ProjectedPoint, nil, nil, QueryEvent)
    return bSuccess, ProjectedPoint
end
function LTask_AiMoveBase:GetAccectableRadius()
    if self:GetNavTarget().IsA then
        local Movement = self:GetNavTarget():GetMovementComponent()
        if Movement then
            return self.StaticAcceptRadius + Movement.NavAgentProps.AgentRadius
        end
    end
    return self.StaticAcceptRadius
end
---@return AActor | FVector
function LTask_AiMoveBase:GetNavTarget()
    -- return self.Chr.NpcComp.Role.BB.MoveTarget
    ---@todo
    return UE.UGameplayStatics.GetPlayerPawn(self.Chr, 0):K2_GetActorLocation()
end
-- 通知其他模块
function LTask_AiMoveBase:OnMoveStucked()
    log.error('AiMoveBase: Chr Stucked !')
    self:DoTerminate(false)
end