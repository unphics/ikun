---
---@brief 简单的平滑转身
---@author zys
---@data Sun Jan 26 2025 20:13:53 GMT+0800 (中国标准时间)
---

---@class LTask_RotateSmooth: LTask
---@field ConstRotSpeed number
---@field ConstFillInThreshold number
local LTask_RotateSmooth = class.class 'LTask_RotateSmooth' : extends 'LTask' {
--[[public]]
    ctor = function()end,
--[[private]]
    OnInit = function()end,
    OnUpdate = function()end,
    ConstRotSpeed = nil,
}
---@param RotSpeed number 转身速度, 单位是角度
---@param ConstFillInThreshold number 进入转身的门槛
function LTask_RotateSmooth:ctor(DisplayName, RotSpeed, FillInThreshold)
    class.LTask.ctor(self, DisplayName)
    self.ConstRotSpeed = RotSpeed or 300
    self.ConstFillInThreshold = FillInThreshold or 10
end
function LTask_RotateSmooth:OnInit()
    class.LTask.OnInit(self)

    self.TimeCount = 0
    self.TargetRot = nil
    self.DeltaRot = nil

    self.InitRot = self.Chr:K2_GetActorRotation() ---@type FRotator
    local TargetLoc = self:GetRotateTarget()
    local AgentLoc = self.Chr:K2_GetActorLocation() -- self.Chr:GetNavAgentLocation()
    local DirLoc = TargetLoc - AgentLoc
    
    self.TargetRot = UE.UKismetMathLibrary.Conv_VectorToRotator(DirLoc)
    ---@note 左转是负, 右转是正
    self.DeltaRot = UE.UKismetMathLibrary.NormalizedDeltaRotator(self.TargetRot, self.InitRot)

    if math.abs(self.DeltaRot.Yaw) < self.ConstFillInThreshold then
        self:DoTerminate(true)
    end
end
function LTask_RotateSmooth:OnUpdate(DeltaTime)
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
        log.error('LTask_RotateSmooth:OnUpdate Failed to index Chr !', obj_util.get_obj_name(self.Chr))
    end
    self.Chr:K2_AddActorLocalRotation(UE.FRotator(0, Yaw, 0), true, nil, true)
    local CurRot = self.Chr:K2_GetActorRotation()
    local DeltaRot = UE.UKismetMathLibrary.NormalizedDeltaRotator(self.TargetRot, CurRot)
    if math.abs(DeltaRot.Yaw) < 5 then
        self:DoTerminate(true)
    end
end
---@private [no sad effect]
---@return AActor | FVector
function LTask_RotateSmooth:GetRotateTarget()
    local MoveTarget = self.Blackboard:GetBBValue('MoveTarget')
    if not MoveTarget then
        log.error('LTask_RotateSmooth:OnInit Failed to index MoveTarget !')
        return
    end
    if class.instanceof(MoveTarget, class.RoleClass) then
        MoveTarget = MoveTarget.Avatar:K2_GetActorLocation()
    end
    if not MoveTarget then
        log.error('LTask_RotateSmooth:OnInit Failed to index valid MoveTarget !')
    end
    return MoveTarget
end