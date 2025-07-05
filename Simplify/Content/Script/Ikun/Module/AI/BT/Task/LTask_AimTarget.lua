
---
---@brief 转身瞄准
---@author zys
---@data Sat May 03 2025 19:07:52 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LTask_AimTarget: LTask
---@field ConstRotSpeed number
---@field ConstFillInThreshold number
local LTask_AimTarget = class.class 'LTask_AimTarget' : extends 'LTask' {
--[[public]]
    ctor = function()end,
--[[private]]
    OnInit = function()end,
    OnUpdate = function()end,
    ConstRotSpeed = nil,
}
---@param RotSpeed number 转身速度, 单位是角度
---@param ConstFillInThreshold number 进入转身的门槛
function LTask_AimTarget:ctor(NodeDispName, RotSpeed, FillInThreshold)
    class.LTask.ctor(self, NodeDispName)
    self.ConstRotSpeed = RotSpeed or 300
    self.ConstFillInThreshold = FillInThreshold or 1
end
function LTask_AimTarget:OnInit()
    class.LTask.OnInit(self)

    self.TimeCount = 0
    self.TargetRot = nil
    self.DeltaRot = nil

    self.InitRot = self.Chr:K2_GetActorRotation() ---@type FRotator
    local TargetLoc = self:GetAimTargetLoc()
    if not TargetLoc then
        self:DoTerminate(false)
        return
    end
    local AgentLoc = self.Chr:K2_GetActorLocation() -- self.Chr:GetNavAgentLocation()
    local DirLoc = TargetLoc - AgentLoc
    
    self.TargetRot = UE.UKismetMathLibrary.Conv_VectorToRotator(DirLoc)
    ---@note 左转是负, 右转是正
    self.DeltaRot = UE.UKismetMathLibrary.NormalizedDeltaRotator(self.TargetRot, self.InitRot)

    if math.abs(self.DeltaRot.Yaw) < self.ConstFillInThreshold then
        self:DoTerminate(true)
    end
end
function LTask_AimTarget:OnUpdate(DeltaTime)
    if not self.TargetRot then
        self:DoTerminate(false)
        return
    end
    if not self.ConstRotSpeed then
        self:DoTerminate(false)
        return
    end
    -- self.TimeCount = self.TimeCount + DeltaTime
    local Yaw = (self.DeltaRot.Yaw > 0 and self.ConstRotSpeed or -self.ConstRotSpeed) * DeltaTime
    if not obj_util.is_valid(self.Chr) then
        log.error('LTask_AimTarget:OnUpdate Failed to index Chr !', obj_util.get_obj_name(self.Chr))
    end
    local CurRot = self.Chr:K2_GetActorRotation()
    local DeltaRot = UE.UKismetMathLibrary.NormalizedDeltaRotator(self.TargetRot, CurRot)
    Yaw = (math.abs(DeltaRot.Yaw) > math.abs(Yaw)) and Yaw or DeltaRot.Yaw
    self.Chr:K2_AddActorLocalRotation(UE.FRotator(0, Yaw, 0), true, nil, true)
    CurRot = self.Chr:K2_GetActorRotation()
    DeltaRot = UE.UKismetMathLibrary.NormalizedDeltaRotator(self.TargetRot, CurRot)
    if math.abs(DeltaRot.Yaw) < self.ConstFillInThreshold then
        self:DoTerminate(true)
    end
end
---@private [no sad effect]
---@return AActor | FVector
function LTask_AimTarget:GetAimTargetLoc()
    local AimTarget = self.Blackboard:GetBBValue(BBKeyDef.FightTarget)
    if not AimTarget then
        log.error('LTask_AimTarget:AimTarget() not AimTarget')
        return
    end
    return AimTarget.Avatar:K2_GetActorLocation()
end