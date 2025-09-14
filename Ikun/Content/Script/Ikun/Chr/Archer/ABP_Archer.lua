
---
---@brief   动画蓝图
---@author  zys
---@data    Sun Jul 20 2025 12:27:04 GMT+0800 (中国标准时间)
---@note    2025年7月30日23:55:40: 开始处理旋转的时候要把OrientRotationToMovement关掉, 同时UseControllerRotationYaw也要关掉
---


local VelBlendStruct = UE.UObject.Load('/Game/Ikun/Blueprint/Anim/VelBlend.VelBlend') ---@type FVelBlend
local MoveDirEnum = UE.UObject.Load('/Game/Ikun/Blueprint/Anim/MoveDir.MoveDir') ---@type MoveDir

---@class ABP_Archer: ABP_Archer_C
---@field Chr BP_ChrBase
local ABP_Archer = UnLua.Class()

-- function ABP_Archer:Initialize(Initializer)
-- end

-- function ABP_Archer:BlueprintInitializeAnimation()
-- end

---@override
function ABP_Archer:BlueprintBeginPlay()
    if self:TryGetPawnOwner().GetRole then
        self.Chr = self:TryGetPawnOwner()
    end
end

---@override Tick
function ABP_Archer:BlueprintUpdateAnimation(DeltaTimeX)
    if not self.Chr then
        return
    end
    if net_util.is_server(self.Chr) then
        return
    end
    self:UpdateFightInfo()
    self:UpdateMoveSpeed(DeltaTimeX)
    self:UpdateTurnInfo(DeltaTimeX)
    
    self:UpdateCacheVal()
end

---@override
-- function ABP_Archer:BlueprintPostEvaluateAnimation()
-- end

---@private 更新有关入战出战的相关信息
function ABP_Archer:UpdateFightInfo()
    self.bInFight = gas_util.has_loose_tag(self.Chr, 'Role.State.InFight')
end

---@private 更新地面移动有关信息
function ABP_Archer:UpdateMoveSpeed(DeltaTime)
    do -- 计算速度的标量大小
        local worldVel = self.Chr:GetVelocity()
        worldVel.Z = 0
        self.Speed = UE.UKismetMathLibrary.VSize(worldVel)
    end
    do -- 计算速度的方向混合
        ---@step 1.计算此时瞬时混合速度
        local worldVel = self.Chr:GetVelocity() -- 这是一个世界空间的速度
        local worldRot = self.Chr:K2_GetActorRotation()
        local worldVelDir = UE.UKismetMathLibrary.Normal(worldVel, 0.0001) -- tolerance:公差
        local relVelDir = UE.UKismetMathLibrary.LessLess_VectorRotator(worldVelDir, worldRot) ---@type FVector 将世界空间的速度转成角色本地空间的速度

        local velSumCount = math.abs(relVelDir.X) + math.abs(relVelDir.Y) + math.abs(relVelDir.Z)
        local velDirPer = relVelDir / velSumCount ---@type FVector 归一化的相对速度, 每个值都是百分比占比量
    
        local velBelnd = VelBlendStruct() ---@type FVelBlend
        velBelnd.F = math_util.clamp(velDirPer.X, 0, 1)
        velBelnd.B = math.abs(math_util.clamp(velDirPer.X, -1, 0))
        velBelnd.L = math.abs(math_util.clamp(velDirPer.Y, -1, 0))
        velBelnd.R = math_util.clamp(velDirPer.Y, 0, 1)

        ---@step 2.将当前混合速度插值到此时的瞬时混合速度
        local interp_speed = 50
        self.VelBlend.F = UE.UKismetMathLibrary.FInterpTo(self.VelBlend.F, velBelnd.F, DeltaTime, interp_speed)
        self.VelBlend.B = UE.UKismetMathLibrary.FInterpTo(self.VelBlend.B, velBelnd.B, DeltaTime, interp_speed)
        self.VelBlend.L = UE.UKismetMathLibrary.FInterpTo(self.VelBlend.L, velBelnd.L, DeltaTime, interp_speed)
        self.VelBlend.R = UE.UKismetMathLibrary.FInterpTo(self.VelBlend.R, velBelnd.R, DeltaTime, interp_speed)
    end

    do -- 计算移动方向枚举值
        local aimRot = self.Chr:GetControlRotation()
        local worldVel = self.Chr:GetVelocity()
        local worldVelRot = UE.UKismetMathLibrary.Conv_VectorToRotator(worldVel)
        local localVelRot = UE.UKismetMathLibrary.NormalizedDeltaRotator(worldVelRot, aimRot)
        local IsAngleInRage = function(Angle, MinAngle, MaxAngle, Buffer, bIncreaseBuffer)
            if bIncreaseBuffer then
                return UE.UKismetMathLibrary.InRange_FloatFloat(Angle, MinAngle - Buffer, MaxAngle + Buffer, true, true)
            else
                return UE.UKismetMathLibrary.InRange_FloatFloat(Angle, MinAngle + Buffer, MaxAngle - Buffer, true, true)
            end
        end
        local CalcQuadrant = function(CurDir, FRThreshold, FLThreshold, BRThreshold, BLThreshold, Buffer, Angle)
            if IsAngleInRage(Angle, FLThreshold, FRThreshold, Buffer, CurDir ~= MoveDirEnum.Forward or CurDir ~= MoveDirEnum.Back) then
                return MoveDirEnum.Forward
            elseif IsAngleInRage(Angle, FRThreshold, BRThreshold, Buffer, CurDir ~= MoveDirEnum.Right or CurDir ~= MoveDirEnum.Left) then
                return MoveDirEnum.Right
            elseif IsAngleInRage(Angle, BLThreshold, FLThreshold, Buffer, CurDir ~= MoveDirEnum.Forward or CurDir ~= MoveDirEnum.Back) then
                return MoveDirEnum.Left
            else
                return MoveDirEnum.Back
            end
        end
        self.MoveDir = CalcQuadrant(self.MoveDir, 70, -70, 110, -110, 5, localVelRot.Yaw)
    end

    do
        local AimRot = self.Chr:GetControlRotation()
        self.AimYaw = AimRot.Yaw
        self.AimPitch = AimRot.Pitch
    end
end

---@private 更新角色的转身信息
function ABP_Archer:UpdateTurnInfo(DeltaTime)
    do
        if self.CachedPrevAimYaw then
            local deltaYaw = self.Chr:GetControlRotation().Yaw - self.CachedPrevAimYaw
            local aimYawRate = math.abs(deltaYaw / DeltaTime)
        end
    end
end

---@private 缓存一些上一帧的信息用来做插值计算
function ABP_Archer:UpdateCacheVal()
    self.CachedPrevAimYaw = self.Chr:GetControlRotation().Yaw
end

return ABP_Archer