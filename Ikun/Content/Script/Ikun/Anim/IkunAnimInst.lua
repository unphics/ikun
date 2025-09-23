---
---@brief 
---

-- local EGait = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/Gait.Gait')
-- local EMoveDir = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/MoveDir.MoveDir')
-- local EMoveState = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/MoveState.MoveState')
-- local ERotMode = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/RotMode.RotMode')
-- local EStance = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/Stance.Stance')
-- local EViewModel = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/ViewModel.ViewModel')

-- local BP_ChrBase = UE.UClass.Load('/Game/Ikun/Chr/Blueprint/BP_ChrBase.BP_ChrBase_C')
-- local StructLeanAmount = UE.UObject.Load('/Game/Ikun/Chr/Blueprint/Structure/LeanAmount.LeanAmount')
-- local StructVelBlend = UE.UObject.Load('/Game/Ikun/Chr/Blueprint/Structure/VelBlend.VelBlend')

---@class IkunAnimInst: IkunAnimInst_C
local IkunAnimInst = UnLua.Class()

local function format(num)
    return string.format('%08.4f', num)
end

--- MapRangeClamped
---@param Val number
---@param InMin number
---@param InMax number
---@param OutMin number
---@param OutMax number
local function Remap(Val, InMin, InMax, OutMin, OutMax)
    local NormalizeVal = (Val - InMin) / (InMax - InMin)
    return NormalizeVal * (OutMax - OutMin) + OutMin
end

---@param Angle number
---@param MinAngle number
---@param MaxAngle number
---@param Buffer number
---@param InCreaseBuf boolean
---@return boolean
local function AngleInRange(Angle, MinAngle, MaxAngle, Buffer, InCreaseBuf)
    if InCreaseBuf then
        return UE.UKismetMathLibrary.InRange_FloatFloat(Angle, MinAngle - Buffer, MaxAngle + Buffer, true, true)
    else
        return UE.UKismetMathLibrary.InRange_FloatFloat(Angle, MinAngle + Buffer, MaxAngle - Buffer, true, true)
    end
end

-- function IkunAnimInst:Initialize(Initializer)
-- end

-- function IkunAnimInst:BlueprintInitializeAnimation()
-- end

function IkunAnimInst:BlueprintBeginPlay()
    do return end
    if self:TryGetPawnOwner():Cast(BP_ChrBase) then
        self.Chr = self:TryGetPawnOwner():Cast(BP_ChrBase)
    else
        log.error("ABP_Man:BlueprintBeginPlay()", 'Failed To Gait Chr')
    end
end

---@override [Tick]
function IkunAnimInst:BlueprintUpdateAnimation(DeltaTimeX)
    do return end
    self.DeltaTimeX = DeltaTimeX
    if DeltaTimeX ~= 0 then
        if not UE.UKismetSystemLibrary.IsValid(self.Chr) then
            return
        end
        self:UpdateChrInfo()
        self:UpdateAimVal()
        if self.MoveState == EMoveState.Ground then
            local ShouldMove = self:CheckShouldMove()
            if self.ShouldMove and ShouldMove then
                -- 运动状态
                self:UpdateMoveVal()
                self:UpdateRotVal()
            elseif not self.ShouldMove and not ShouldMove then
                -- 静止状态
                if self:CanRotateInPlace() then
                    self:RotateInPlaceCheck()
                else
                    self.RotL = false
                    self.RotR = false
                end
                if self:CanTurnInPlace() then
                    self:TurnInPlaceCheck()
                else
                    self.ElapsedDelayTime = 0
                end
            elseif not self.ShouldMove and ShouldMove then
                self.RotL = false
                self.RotR = false
                self.ElapsedDelayTime = 0
            end
            self.ShouldMove = ShouldMove
        elseif self.MoveState == EMoveState.InAir then
        end
    end
end

-- function IkunAnimInst:BlueprintPostEvaluateAnimation()
-- end

---@private [Update] 
function IkunAnimInst:UpdateChrInfo()
    self.InFight = gas_util.has_loose_tag(self.Chr, 'Chr.State.InFight')
    self.Vel, self.Acc, self.MoveInput, self.IsMove, self.HasMoveInput, self.Speed, self.MoveInputAmount, self.AimRot, self.AimYawRate = self.Chr.AnimComp:GetEssentialVal()
    self.MoveState, self.RotMode, self.Gait, self.Stance, self.ViewModel = self.Chr.AnimComp:GetChrState()
end

---@private [Update]
function IkunAnimInst:UpdateAimVal()
    self.SmoothAimRot = UE.UKismetMathLibrary.RInterpTo(self.SmoothAimRot, self.AimRot, self.DeltaTimeX, self.CfgSmoothAimRotInterpSpeed) -- 平滑当前Rot
    local ResultRot = UE.UKismetMathLibrary.NormalizedDeltaRotator(self.AimRot, self.Chr:K2_GetActorRotation())
    self.AimAngle.X = ResultRot.Yaw
    self.AimAngle.Y = ResultRot.Pitch
    ResultRot = UE.UKismetMathLibrary.NormalizedDeltaRotator(self.SmoothAimRot, self.Chr:K2_GetActorRotation())
    self.SmoothAimAngle.X = ResultRot.Yaw
    self.SmoothAimAngle.Y = ResultRot.Pitch
    if (self.RotMode == ERotMode.LookDir) or (self.RotMode == ERotMode.AimDir) then
        self.AimSweepTime = Remap(self.AimAngle.X, -90, 90, 1, 0)
        self.SpineRot.Yaw = self.AimAngle.X / 4
    elseif self.RotMode == ERotMode.VelDir then
        if self.HasMoveInput then
            local a = UE.UKismetMathLibrary.Conv_VectorToRotator(self.MoveInput)
            local b = UE.UKismetMathLibrary.NormalizedDeltaRotator(a, self.Chr:K2_GetActorRotation())
            self.InputYawOffsetTime = UE.UKismetMathLibrary.FInterpTo(self.InputYawOffsetTime, Remap(b.Yaw, -180, 180, 0, 1), self.DeltaTimeX, self.CfgInputYawOffsetInterpSpeed)
        end
    end
    self.LeftYawTime = Remap(math.abs(self.SmoothAimAngle.X), 0, 180, 0.5, 0)
    self.RightYawTime = Remap(math.abs(self.SmoothAimAngle.X), 0, 180, 0.5, 1)
    self.FwdYawTime = Remap(self.SmoothAimAngle.X, -180, 180, 0, 1)
end

---@private [Update] 
function IkunAnimInst:UpdateMoveVal()
    -- 插值并设定"速度混合"这个值是骨骼网格体空间中的各个方向的速度分量
    self.VelBlend = self:InterpVelBlend(self.VelBlend, self:CalcVelBlend(), self.CfgVelBlendInterpSpeed, self.DeltaTimeX)
    -- 设置"相对加速度"并插入"倾斜量";角色空间
    self.RelativeAccAmount = self:CalcRelativeAccAmount()
    -- 加速度的量就是倾斜量
    local StructLeanAmount = StructLeanAmount()
    StructLeanAmount.LR = self.RelativeAccAmount.Y
    StructLeanAmount.FB = self.RelativeAccAmount.X
    self.LeanAmount = self:InterpLeanAmount(self.LeanAmount, StructLeanAmount, self.CfgGoundLeanInterpSpeed, self.DeltaTimeX)

    self.WalkRunBlend = self:CalcWalkRunBlend()
    self.StrideBlend = self:CalcStrideBlend()
    self.StandPlayRate = self:CalcStandPlayRate()
    -- TODO self.CrouchPlayRate = CalcCrouchPlayRate(self)
end

---@private [Update] 
function IkunAnimInst:UpdateRotVal()
    self.MoveDir = self:CalcMoveDir()

    -- 设置偏航偏移。这些值会影响动画图中的“YawOffset”曲线，并用于偏移角色旋转以获得更自然的移动。曲线允许对偏移在每个移动方向上的行为进行精细控制。
    local DeltaRot = UE.UKismetMathLibrary.NormalizedDeltaRotator(UE.UKismetMathLibrary.Conv_VectorToRotator(self.Vel), self.Chr:GetControlRotation())
    local FB = self.YawOffsetFB:GetVectorValue(DeltaRot.Yaw)
    local LR = self.YawOffsetLR:GetVectorValue(DeltaRot.Yaw)
    self.FYaw = FB.X
    self.BYaw = FB.Y
    self.LYaw = LR.X
    self.RYaw = LR.Y
end

---@private [Ground] 
function IkunAnimInst:CheckShouldMove()
    return (self.IsMove and self.HasMoveInput) or (self.Speed > 150)
end

---@private [Ground] 
---@return boolean
function IkunAnimInst:CanRotateInPlace()
    return self.RotMode == ERotMode.AimDir
end

---@private [Ground] 
function IkunAnimInst:RotateInPlaceCheck()
    self.RotL = self.AimAngle.X < self.RotateMinThreshold
    self.RotR = self.AimAngle.X > self.RotateMaxThreshold
    if self.RotL or self.RotR then
        self.RotRate = UE.UKismetMathLibrary.MapRangeClamped(self.AimYawRate, self.AimYawRateMinRange, self.AimYawRateMinRange, self.MinPlayRate, self.MaxPlayRate)
    end
end

---@private [Ground] 
---@return boolean
function IkunAnimInst:CanTurnInPlace()
    return (self.RotMode == ERotMode.LookDir) and (self:GetCurveValue('Enable_Transition') > 0.99)
end

---@private [Ground] 
function IkunAnimInst:TurnInPlaceCheck()
    if (math.abs(self.AimAngle.X) > self.TurnCheckMinAngle) then -- and (self.AimYawRate < self.AimYawRateLimit) then
        self.ElapsedDelayTime = self.ElapsedDelayTime + self.DeltaTimeX
        -- log.warn('zys ', format(self.ElapsedDelayTime), format(math.abs(self.AimAngle.X)), Remap(math.abs(self.AimAngle.X), self.TurnCheckMinAngle, 180, self.MinAngleDelay, self.MaxAngleDelay))
        if self.ElapsedDelayTime > Remap(math.abs(self.AimAngle.X), self.TurnCheckMinAngle, 180, self.MinAngleDelay, self.MaxAngleDelay) then
            self:TurnInPlace(UE.FRotator(0, self.AimRot.Yaw, 0), 1, 0, false)
        end
    else
        self.ElapsedDelayTime = 0
    end
end

---@private [Ground] 
function IkunAnimInst:TurnInPlace(TarRot, PlayRateScale, Start, Override)
    local TurnAngle = UE.UKismetMathLibrary.NormalizedDeltaRotator(TarRot, self.Chr:K2_GetActorRotation()).Yaw
    log.log('anim inst', 'turn angle : ', format(TurnAngle), ', tar:', format(TarRot.Yaw), ', cur:', format(self.Chr:K2_GetActorRotation().Yaw))
    local TarTurnAsset = nil
    if math.abs(TurnAngle) < 130 then -- 小于则为90, 大于则为180
        if TurnAngle < 0 then -- 左
            if self.Stance == EStance.Stand then
                TarTurnAsset = self.N_TurnIP_L90
            elseif self.Stance == EStance.Crouch then
                TarTurnAsset = self.CLF_TurnIP_L90
            end
        else
            if self.Stance == EStance.Stand then
                TarTurnAsset = self.N_TurnIP_R90
            elseif self.Stance == EStance.Crouch then
                TarTurnAsset = self.CLF_TurnIP_R90
            end
        end
    else
        if TurnAngle < 0 then
            if self.Stance == EStance.Stand then
                TarTurnAsset = self.N_TurnIP_L180
            elseif self.Stance == EStance.Crouch then
                TarTurnAsset = self.CLF_TurnIP_L180
            end
        else
            if self.Stance == EStance.Stand then
                TarTurnAsset = self.N_TurnIP_R180
            elseif self.Stance == EStance.Crouch then
                TarTurnAsset = self.CLF_TurnIP_R180
            end
        end
    end
    if Override or not self:IsPlayingSlotAnimation(TarTurnAsset.Animation, TarTurnAsset.SlotName) then
        log.log('anim inst', 'play mtg', TarTurnAsset.AnimatedAngle)
        self:PlaySlotAnimationAsDynamicMontage(TarTurnAsset.Animation, "DefaultSlot"--[[TarTurnAsset.SlotName]], 0.2, 0.2, TarTurnAsset.PlayRate * PlayRateScale, 1, 0, Start)
        if TarTurnAsset.ScaleTurnAngle then
            self.RotScale = (TurnAngle /--[[真实TurnAngle(如70/80)比资源要求的TurnAngle(如90)]] TarTurnAsset.AnimatedAngle) * --[[按真实角度对于资源要求角度的完成率重新修正一次旋转缩放]]
                (TarTurnAsset.PlayRate * PlayRateScale)
        else
            self.RotScale = TarTurnAsset.PlayRate * PlayRateScale
        end
    end
end

---@private [Move] 
---@return StructVelBlend
function IkunAnimInst:CalcVelBlend()
    local RelativeVelDir = UE.UKismetMathLibrary.LessLess_VectorRotator(UE.UKismetMathLibrary.Normal(self.Vel, 0.1), self.Chr:K2_GetActorRotation())
    local Sum = math.abs(RelativeVelDir.X) + math.abs(RelativeVelDir.Y) + math.abs(RelativeVelDir.Z)
    local RelativeDir = RelativeVelDir / Sum
    local StructVelBlend = StructVelBlend()
    StructVelBlend.F = UE.UKismetMathLibrary.FClamp(RelativeDir.X, 0, 1)
    StructVelBlend.B = math.abs(UE.UKismetMathLibrary.FClamp(RelativeDir.X, -1, 0))
    StructVelBlend.L = math.abs(UE.UKismetMathLibrary.FClamp(RelativeDir.Y, -1, 0))
    StructVelBlend.R = UE.UKismetMathLibrary.FClamp(RelativeDir.Y, 0, 1)
    return StructVelBlend
end

---@private [Move] 
---@return number
function IkunAnimInst:CalcWalkRunBlend()
    return self.Gait == EGait.Walk and 0 or 1
end

---@private [Move] 
---@return number
function IkunAnimInst:CalcStrideBlend()
    local Walk = Remap(self.Speed, 0, 150, 0, 1)
    local Run = Remap(self.Speed, 0, 350, 0, 1)
    local Lerp = UE.UKismetMathLibrary.Lerp(Walk, Run, self:GetAnimCurveClamped('Weight_Gait', -1, 0, 1))
    local Crouch = Remap(self.Speed, 0, 150, 0, 1)
    return UE.UKismetMathLibrary.Lerp(Lerp, Crouch, self:GetCurveValue('BasePose_CLF'))
end

---@private [Move] 通过将角色的速度除以每个步态的动画速度来计算播放速率。lerp由每个运动循环中存在的“Weight_Gait”动画曲线确定，因此播放速率始终与当前混合的动画同步。该值还除以“步幅混合”（Stride Blend）和网格比例，以便播放速率随着步幅或比例变小而增加。
---@return number
function IkunAnimInst:CalcStandPlayRate()
    local WalkRun = UE.UKismetMathLibrary.Lerp(self.Speed / self.CfgAnimatedWalkSpeed, self.Speed / self.cfgAnimatedRunSpeed, self:GetAnimCurveClamped('Weight_Gait', -1, 0, 1))
    local WalkRunStride = UE.UKismetMathLibrary.Lerp(WalkRun, self.Speed / self.CfgAnimatedSprideSpeed, self:GetAnimCurveClamped('Weight_Gait', -2, 0, 1))
    return UE.UKismetMathLibrary.FClamp((WalkRunStride / self.StrideBlend) / self:GetOwningComponent():K2_GetComponentScale().Z, 0, 3) -- K2_GetComponentScale蓝图中是GetWroldScale
end

---@private [Rot] 计算移动方向。该值表示在“环视/瞄准”旋转模式期间角色相对于摄影机移动的方向，并在“循环混合动画层”中用于混合到适当的方向状态。
function IkunAnimInst:CalcMoveDir()
    if self.Gait ~= EGait.Sprint then
        if self.RotMode == ERotMode.VelDir then
            return EMoveDir.Forward
        else
            -- 得到网格体空间下的速度
            local LocalSpeed = UE.UKismetMathLibrary.NormalizedDeltaRotator(UE.UKismetMathLibrary.Conv_VectorToRotator(self.Vel), self.AimRot)
            return self:CalcQuadrant(self.MoveDir, 70, -70, 110, -110, 5, LocalSpeed.Yaw)
        end
    else
        return EMoveDir.Forward
    end
end

---@private [Rot] 取输入角度并确定其象限（方向）。使用当前的“移动方向”可以增加或减少每个象限的角度范围上的缓冲区。
---@param Cur EMoveDir
---@param FRThreshold number
---@param FLThreshold number
---@param BRThreshold number
---@param BLThreshold number
---@param Buffer number
---@param Angle number
function IkunAnimInst:CalcQuadrant(Cur, FRThreshold, FLThreshold, BRThreshold, BLThreshold, Buffer, Angle)
    if AngleInRange(Angle, FLThreshold, FRThreshold, Buffer, (Cur ~= EMoveDir.Forward) or (Cur ~= EMoveDir.Back)) then
        return EMoveDir.Forward
    elseif AngleInRange(Angle, FRThreshold, BRThreshold, Buffer, (Cur ~= EMoveDir.Right) or (Cur ~= EMoveDir.Left)) then
        return EMoveDir.Right
    elseif AngleInRange(Angle, BLThreshold, FLThreshold, Buffer, (Cur ~= EMoveDir.Right) or (Cur ~= EMoveDir.Left)) then
        return EMoveDir.Left
    else
        return EMoveDir.Back
    end
end

---@private [Interp] 
---@param Cur StructVelBlend
---@param Tar StructVelBlend
---@param Speed number
---@param DeltaX number
function IkunAnimInst:InterpVelBlend(Cur, Tar, Speed, DeltaX)
    local StructVelBlend = StructVelBlend()
    StructVelBlend.F = UE.UKismetMathLibrary.FInterpTo(Cur.F, Tar.F, DeltaX, Speed)
    StructVelBlend.B = UE.UKismetMathLibrary.FInterpTo(Cur.B, Tar.B, DeltaX, Speed)
    StructVelBlend.L = UE.UKismetMathLibrary.FInterpTo(Cur.L, Tar.L, DeltaX, Speed)
    StructVelBlend.R = UE.UKismetMathLibrary.FInterpTo(Cur.R, Tar.R, DeltaX, Speed)
    -- log.warn('InterpVelBlend', 'F:', StructVelBlend.F, ', B:', StructVelBlend.B,', L:', StructVelBlend.L, ', R: ', StructVelBlend.R)
    return StructVelBlend
end

---@private [Interp] 
---@param Cur StructLeanAmount
---@param Tar StructLeanAmount
---@param Speed number
---@param DeltaX number
---@return StructLeanAmount
function IkunAnimInst:InterpLeanAmount(Cur, Tar, Speed, DeltaX)
    local StructLeanAmount = StructLeanAmount()
    StructLeanAmount.LR = UE.UKismetMathLibrary.FInterpTo(Cur.LR, Tar.LR, DeltaX, Speed)
    StructLeanAmount.FB = UE.UKismetMathLibrary.FInterpTo(Cur.FB, Tar.FB, DeltaX, Speed)
    return StructLeanAmount
end

---@private [] 计算相对加速度。该值表示相对于演员旋转的当前加速/减速量。它被规格化为-1到1的范围，因此-1等于“最大制动减速度”，1等于“角色移动组件”的“最大加速度”。
---@return UE.FVector
function IkunAnimInst:CalcRelativeAccAmount()
    local ActorRot = self.Chr:K2_GetActorRotation()
    if UE.UKismetMathLibrary.Dot_VectorVector(self.Vel, self.Acc) > 0 then -- 判断角色加速减速
        local MaxAcc = self.Chr.CharacterMovement:GetMaxAcceleration()
        local Clamped = UE.UKismetMathLibrary.Vector_ClampSizeMax(self.Acc, MaxAcc)
        return UE.UKismetMathLibrary.LessLess_VectorRotator(Clamped, ActorRot) / MaxAcc
    else
        local MaxBrakingDec = self.Chr.CharacterMovement:GetMaxBrakingDeceleration()
        local Clamped = UE.UKismetMathLibrary.Vector_ClampSizeMax(self.Acc, MaxBrakingDec)
        return UE.UKismetMathLibrary.LessLess_VectorRotator(Clamped, ActorRot) / MaxBrakingDec
    end
end

---@private [Uitl] 
---@param Name string
---@param Bais number
---@param ClampedMin number
---@param ClampedMax number
---@return number
function IkunAnimInst:GetAnimCurveClamped(Name, Bais, ClampedMin, ClampedMax)
    local Val = self:GetCurveValue(Name) + Bais
    return UE.UKismetMathLibrary.FClamp(Val, ClampedMin, ClampedMax)
end

return IkunAnimInst