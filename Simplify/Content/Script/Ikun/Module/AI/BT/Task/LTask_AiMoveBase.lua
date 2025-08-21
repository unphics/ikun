---
---@brief Ai移动基础行为任务
---@author zys
---@data Sun Jan 19 2025 20:21:59 GMT+0800 (中国标准时间)
---@todo 1.更多配置项
---      2.更多derive: 和平时起步和停止时缓速, 战斗追击起步缓速, 走位时同和平, 对峙(持续缓速)
---      3.一些地方可以做Cache优化多次访问调用
---      4.这个现在只能处理静态点
---

local NavMoveData = require('Ikun/Module/Nav/NavMoveData')
local MoveStuckMonitor = require('Ikun/Module/Nav/MoveStuckMonitor')
local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LTask_AiMoveBase: LTask
---@field NavTarget AActor | FVector
---@field StaticAcceptRadius number 可接受的抵达半径
---@field StaticMaxStuckTime number 最大阻挡时间
---@field StaticMaxDirGap number 最大方向差
---@field StaticQueryNavExtent FVector 不知道
---@field ConstPathRefreshInterval number 路径刷新间隔
---@field CachedFinalTargetLoc FVector
---@field AccectableRadius number
---@field NavMoveData NavMoveData
---@field MoveStuckMonitor MoveStuckMonitor
local LTask_AiMoveBase = class.class 'LTask_AiMoveBase' : extends 'LTask' {
    ctor = function()end,
    GetTargetLoc = function()end,
    GetNavTarget = function()end,
    OnMoveStucked = function()end,
    ConstPathRefreshInterval = nil,
    StaticQueryNavExtent = nil,
    StaticAcceptRadius = nil,
    StaticMaxStuckTime = nil,
    StaticMaxDirGap = nil,
    CachedFinalTargetLoc = nil,
    AccectableRadius = nil,
    NavMoveData = nil,
    MoveStuckMonitor = nil,
}
function LTask_AiMoveBase:ctor(TaskName, AcceptRadius, MaxDirGap, MaxStuckTime, QueryNavExtent)
    class.LTask.ctor(self, TaskName)

    self.StaticAcceptRadius = AcceptRadius
    self.StaticMaxDirGap = MaxDirGap
    self.StaticMaxStuckTime = MaxStuckTime
    self.StaticQueryNavExtent = QueryNavExtent

    self.ConstPathRefreshInterval = 0.5
    self.CurPathRefreshTimeCount = 0
end
function LTask_AiMoveBase:OnInit()
    class.LTask.OnInit(self)

    ---@step 初始化(重置)Task的数据
    self.CachedFinalTargetLoc = nil
    self.NavMoveData = class.new'NavMoveData'() ---@type NavMoveData
    
    ---@step 检查寻路目标有效
    local TargetLoc = self:GetTargetLoc()
    self.CachedFinalTargetLoc = TargetLoc
    if not TargetLoc then
        self:DoTerminate(false)
        return log.error('AiMoveBase: Invalid Target!')
    end

    ---@step 检查是否已经可以判定抵达
    self.AccectableRadius = self:GetAccectableRadius()
    local SelfChrAgentLoc = self.Chr:GetNavAgentLocation() ---@todo 如果这个也是Project点的话这段逻辑有问题
    self.MoveStuckMonitor = class.new'MoveStuckMonitor'(self.StaticMaxStuckTime, SelfChrAgentLoc)
    local Distance = UE.UKismetMathLibrary.Vector_Distance(SelfChrAgentLoc, TargetLoc)
    if Distance < self.AccectableRadius then
        self:DoTerminate(true)
        return log.debug('AiMoveBase: Already Reached Target Initially !')
    end

    ---@step 如果目标不在导航网格内, 就在可接受的范围内尝试找一个最近的NavMesh点
    if not self.NavMoveData:GenPathData(self.Chr, SelfChrAgentLoc, TargetLoc) then
        local bTargetReachable = class.NavMoveData.ProjectPointToNavMesh(self.Chr, TargetLoc)
        ---@todo 对于复杂行为的Npc,可以尝试从目标身上获取一个可达点
        if bTargetReachable then
            local bSelfMovable, NearNavPoint = class.NavMoveData.ProjectPointToNavMesh(self.Chr, SelfChrAgentLoc, self.StaticQueryNavExtent)
            if bSelfMovable then
                self.NavMoveData:GenPathData(self.Chr, NearNavPoint, TargetLoc, SelfChrAgentLoc) ---@todo 待验证此处First
            end
        end
        if not self.NavMoveData:IsValid() then
            self:OnMoveStucked()
            return log.error('AiMoveBase: Failed to get valid seg !')
        end
    end

    ---@step 检查面朝方向与寻路方向差距过大
    if not self:CheckDirGap() then
        self:DoTerminate(false)
        return log.error('AiMoveBase: Need to Face to Target !')
    end
end
function LTask_AiMoveBase:OnUpdate(DeltaTime)
    self.CurPathRefreshTimeCount = self.CurPathRefreshTimeCount + DeltaTime
    ---@step 判断跑完了最后一个寻路段
    if self.NavMoveData:IsFinish() then
        self:DoTerminate(true)
        return -- log.debug('AiMoveBase: Ai Move Reached !')
    end
    local SelfChrAgentLoc = self.Chr:GetNavAgentLocation()
    ---@todo About First Point

    ---@todo 判断目标在移动(GenPathData是高消耗操作所以要定时)
    -- if self.CurPathRefreshTimeCount > self.ConstPathRefreshInterval then
    --     self.NavMoveData:GenPathData(self.Chr, SelfChrAgentLoc, self.CachedFinalTargetLoc)
    --     self.CurPathRefreshTimeCount = self.CurPathRefreshTimeCount - self.ConstPathRefreshInterval
    -- end

    ---@step 实时检查是否被阻挡
    if self.MoveStuckMonitor:TickCheck(DeltaTime, SelfChrAgentLoc) then
        self:OnMoveStucked()
        return log.error('AiMoveBase: Stucked On Moveing !')
    end

    ---@step 寻路移动
    local Dir = self.NavMoveData:CalcChr2CurSegEndDir2D(self.Chr) ---@type FVector
    Dir:Normalize()
    self.Chr:AddMovementInput(Dir, 1, false)

    ---@step 抵达当前段目标则走下一段
    if self:HasReachedCurSegEnd(0.1) then
        self.NavMoveData:AdvanceSeg()
    end
end
---@private 已经抵达了当前段的目标
---@param RadiusCorr number 半径修正系数
function LTask_AiMoveBase:HasReachedCurSegEnd(RadiusCorr)
    local SelfChrAgentLoc = self.Chr:GetNavAgentLocation()
    local CurSegEndLoc = self.NavMoveData:GetCurSegEnd()
    local Radius = self.AccectableRadius * RadiusCorr
    local Distance = UE.UKismetMathLibrary.Vector_Distance(SelfChrAgentLoc, CurSegEndLoc)
    if Distance < Radius then
        return true
    end
    return false
end
---@private [no sad effect] 检查当前段前进方向是否与面朝方向差距过大
function LTask_AiMoveBase:CheckDirGap()
    local ToCurSegEndDir = self.NavMoveData:CalcChr2CurSegEndDir2D(self.Chr)
    local ToCurSegEndRot = UE.UKismetMathLibrary.Conv_VectorToRotator(ToCurSegEndDir)
    local DeltaRot = UE.UKismetMathLibrary.NormalizedDeltaRotator(ToCurSegEndRot, self.Chr:K2_GetActorRotation())
    if math.abs(DeltaRot.Yaw) > self.StaticMaxDirGap then
        self:DoTerminate(false)
        log.error('AiMoveBase: Dir Gap Too Large !')
        return false
    end
    return true
end
---@private [no sad effect] 获取寻路抵达判定的可接受半径
function LTask_AiMoveBase:GetAccectableRadius()
    if self:GetNavTarget().IsA then
        local Movement = self:GetNavTarget():GetMovementComponent()
        if Movement then
            return self.StaticAcceptRadius + Movement.NavAgentProps.AgentRadius
        end
    end
    return self.StaticAcceptRadius
end
---@private [no sad effect] 获取这次寻路行为的最终地点
---@return FVector | nil
function LTask_AiMoveBase:GetTargetLoc()
    if not self:GetNavTarget() then
        return log.error('AiMoveBase: Invalid Nav Target !')
    end
    ---@step 寻路目标是动态的Actor还是静态的地点分开处理
    if self:GetNavTarget().IsA then
        local bProjectTarget, FixedLoc = class.NavMoveData.ProjectPointToNavMesh(self.Chr, self:GetNavTarget(), self.StaticQueryNavExtent)
        if bProjectTarget then
            return FixedLoc
        else
            return log.error('AiMoveBase: Can not Project Actor To Nav Mesh !')
        end
    else
        if self.CachedFinalTargetLoc then
            return self.CachedFinalTargetLoc
        else
            local bProjectTarget, FixedLoc = class.NavMoveData.ProjectPointToNavMesh(self.Chr, self:GetNavTarget(), self.StaticQueryNavExtent)
            if bProjectTarget then
                self.CachedFinalTargetLoc = FixedLoc
                return FixedLoc
            else
                return log.error('AiMoveBase: Can not Project Target To Nav Mesh !')
            end    
        end
    end
end
---@private [no sad effect] 获取寻路目标, 黑板中的目标可能是一个地点Loc也可能是一个Actor
---@return AActor | FVector | nil
function LTask_AiMoveBase:GetNavTarget()
    local BB_MoveTarget = self.Blackboard:GetBBValue(BBKeyDef.MoveTarget)
    if not BB_MoveTarget then
        return log.error('LTask_AiMoveBase:GetNavTarget(): No MoveTarget')
    end
    if class.instanceof(BB_MoveTarget, class.RoleClass) then
        if not BB_MoveTarget.Avatar then
            return log.error('LTask_AiMoveBase:GetNavTarget(): No Avatar')
        end
        return BB_MoveTarget.Avatar:K2_GetActorLocation()
    end
    if BB_MoveTarget.IsA then
        return BB_MoveTarget:K2_GetActorLocation()
    end
    return BB_MoveTarget
end
---@private 当寻路行为确实被判定为阻挡后调用, 可以用来通知其他模块
function LTask_AiMoveBase:OnMoveStucked()
    log.error('AiMoveBase: Chr Stucked !')
    self:DoTerminate(false)
end