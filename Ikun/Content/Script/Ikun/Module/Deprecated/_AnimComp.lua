--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local EGait = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/Gait.Gait')
local EMoveDir = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/MoveDir.MoveDir')
local EMoveState = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/MoveState.MoveState')
local ERotMode = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/RotMode.RotMode')
local EStance = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/Stance.Stance')
local EViewModel = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/ViewModel.ViewModel')

---@type AnimComp_C
local AnimComp = UnLua.Class()

--- MapRangeClamped
local function Remap(Val, InMin, InMax, OutMin, OutMax)
    local NormalizeVal = (Val - InMin) / (InMax - InMin)
    return NormalizeVal * (OutMax - OutMin) + OutMin
end

-- function AnimComp:Initialize(Initializer)
-- end

function AnimComp:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    if UE.UKismetSystemLibrary.IsValid(self:GetOwner().Mesh:GetAnimInstance()) then
        self.MainAnimInst = self:GetOwner().Mesh:GetAnimInstance()
    end
end

-- function AnimComp:ReceiveEndPlay()
-- end

function AnimComp:ReceiveTick(DeltaSeconds)
    self:SetEssentialVal(DeltaSeconds)
    if self.MoveState == EMoveState.Ground then
        self:UpdateChrMove()
        self:UpdateGroundRot()
    elseif self.MoveState == EMoveState.InAir then
        self:UpdateAirRot()
    end
    self:CacheVal()
end

---@public [interface] 返回chr的motion数据
function AnimComp:GetEssentialVal()
    local Vel = self:GetOwner():GetVelocity() -- 速度
    local Acc = self.Acc -- 加速度
    local MoveInput = self:GetOwner().CharacterMovement:GetCurrentAcceleration() -- 瞬时加速度(输入)
    local IsMove = self.IsMove -- 是否在移动中
    local HasMoveInput = self.HasMoveInput -- 是否有移动输入
    local Speed = self.Speed -- 
    local MoveInputAmount = self.MoveInputAmount -- 移动输入量
    local AimRot = self:GetOwner():GetControlRotation() -- 旋转控制量
    local AimYawRate = self.AimYawRate -- 转向率
    return Vel, Acc, MoveInput, IsMove, HasMoveInput, Speed, MoveInputAmount, AimRot, AimYawRate
end

---@public [interface] 
function AnimComp:GetChrState()
    local MoveState = self.MoveState
    local RotMode = self.RotMode
    local Gait = self.Gait
    local Stance = self.Stance
    local ViewModel = self.ViewModel
    return MoveState, RotMode, Gait, Stance, ViewModel
end


---@private [Essential] 这些值表示胶囊的移动方式以及想要的移动方式, 因此对于任何数据驱动的动画系统都至关重要; 它们也在整个系统中用于各种功能, 所以在一个地方管理
---@param DeltaSeconds number
function AnimComp:SetEssentialVal(DeltaSeconds)
    -- 用速度差得出加速度的值
    self.Acc = (self:GetOwner():GetVelocity() - self.PreVel) / DeltaSeconds
    -- 速度的标量大小
    self.Speed = UE.UKismetMathLibrary.VSize(UE.FVector(self:GetOwner():GetVelocity().X, self:GetOwner():GetVelocity().Y, 0))
    -- 根据角色是否拥有速度来判断角色是否在移动
    self.IsMove = (self.Speed > 0) and true or false
    if self.IsMove then
        -- TODO 没懂
        self.LastVelRot = UE.UKismetMathLibrary.MakeRotFromX(self:GetOwner():GetVelocity())
    end
    -- 移动输入量=当前加速度/最大加速度 判断角色是否有移动输入
    self.MoveInputAmount = UE.UKismetMathLibrary.VSize(self:GetOwner().CharacterMovement:GetCurrentAcceleration()) / self:GetOwner().CharacterMovement:GetMaxAcceleration()
    -- 角色有移动输入量则认为有移动输入
    self.HasMoveInput = (self.MoveInputAmount > 0) and true or false
    -- 当前的偏航速度(当前和上帧偏航差除以DeltaTime)
    self.AimYawRate = UE.UKismetMathLibrary.Abs((self:GetOwner():GetControlRotation().Yaw - self.PreAimYaw) / DeltaSeconds)
end

---@private [Update] 更新角色移动情况
function AnimComp:UpdateChrMove()
    ---@type EGait 允许步态
    local AllowGait = self:GetAllowGait()
    ---@type EGait 实际步态
    local ActualGait = self:GetActualGait(AllowGait)
    if ActualGait ~= self.Gait then
        --TODO BPI_SetGait(ActualGait)
    end
    self:UpdateDynaMoveSetting(AllowGait)
end

---@private 计算允许步态
---@return EGait
function AnimComp:GetAllowGait()
    if self.Stance == EStance.Stand then -- 站姿为站立
        if self.RotMode ~= ERotMode.AimDir then -- VelDir or LookDir
            if self.DesiredGait ~= EGait.Walk then
                return EGait.Walk
            elseif self.DesiredGait ~= EGait.Run then
                return EGait.Run
            else
                return self:CanSprint() and EGait.Sprint or EGait.Run
            end
        end
    end
    -- 蹲伏和瞄准时不能冲刺
    if self.DesiredGait ~= EGait.Walk then
        return EGait.Walk
    else
        return EGait.Run
    end
end

---@private 通过角色的实际移动来计算实际步态; 他可能与所需或允许的步态不同, 例如, 如果"允许步态"变为"行走"，则"实际步态"仍将运行, 直到角色减速到行走速度
---@param AllowGait EGait
---@return EGait
function AnimComp:GetActualGait(AllowGait)
    if self.Speed > self.RunSpeed + 10 then -- 当前实际速度比跑步速度高10才能冲刺
        if AllowGait == EGait.Sprint then
            return EGait.Sprint
        else
            return EGait.Run
        end
    else
        if self.Speed > self.WalkSpeed + 10 then
            return EGait.Run
        else
            return EGait.Walk
        end
    end
end

---@param AllowGait EGait
function AnimComp:UpdateDynaMoveSetting(AllowGait)
    local MoveSetting = self:GetTarMoveSetting()
    self.WalkSpeed = MoveSetting[1]
    self.RunSpeed = MoveSetting[2]
    self.SprintSpeed = MoveSetting[3]
end

---@private 允许冲刺; 
function AnimComp:CanSprint()
    if self.HasMoveInput then
        if self.RotMode == ERotMode.VelDir then
            -- 角色处于速度旋转模式, 且有完整的玩家移动输入则可以冲刺
            return (self.MoveInputAmount > 0.9) and true or false
        elseif self.RotMode == ERotMode.LookDir then
            -- 角色处于注视旋转模式, 则有完整的玩家移动输入而且相对于相机前50度内(视野内)才可以冲刺
            local bAmount = self.MoveInputAmount > 0.9
            local bInView = UE.UKismetMathLibrary.Abs(UE.UKismetMathLibrary.NormalizedDeltaRotator(UE.UKismetMathLibrary.MakeRotFromX(self:GetOwner().CharacterMovement:GetCurrentAcceleration()) , self:GetOwner():GetControlRotation()).Yaw) < 50
            return (bAmount and bInView) and true or false
        end
    end
    return false
end

---@private [Essential] 保存一些上一帧的数据
function AnimComp:CacheVal()
    self.PreVel = self:GetOwner():GetVelocity() -- 上一帧的速度
    self.PreAimYaw = self:GetOwner():GetControlRotation().Yaw -- 上一帧的偏航角
end

---@private [RotSys]
function AnimComp:UpdateGroundRot()
    -- TODO if rolling
    if self:CanUpdateMoveRot() then
        -- 移动中的旋转
        if self.RotMode == ERotMode.VelDir then
            self:SmoothChrRot(UE.FRotator(0, self.LastVelRot.Yaw, 0), 700, self:CalcGroundRotRate())
        elseif self.RotMode == ERotMode.LookDir then
            if self.Gait ~= EGait.Sprint then
                -- TODO self:SmoothChrRot(UE.FRotator(0, 0, self:GetControlRotation().Yaw + GetAnimCurveVal(self, 'YawOffset')), 500, self:CalcGroundRotRate())
                self:SmoothChrRot(UE.FRotator(0, self:GetOwner():GetControlRotation().Yaw, 0), 500, self:CalcGroundRotRate())
            else
                self:SmoothChrRot(UE.FRotator(0, self.LastVelRot.Yaw, 0), 500, self:CalcGroundRotRate())
            end
        elseif self.RotMode == ERotMode.AimDir then
            self:SmoothChrRot(UE.FRotator(0, self:GetOwner():GetControlRotation().Yaw, 0), 1000, 20)
        end
    else
        -- 静止的旋转
        if self.ViewModel == EViewModel.ThirdPerson then
            if self.RotMode ~= ERotMode.AimDir then
            else
                self:LimitRot(-100, 100, 20)
            end
        elseif self.ViewModel == EViewModel.FirstPerson then
            self:LimitRot(-100, 100, 20)
        end
        local RotAmount = self:GetAnimCurveVal('RotationAmount')
        if UE.UKismetMathLibrary.Abs(RotAmount) > 0 then
            self:GetOwner():K2_AddActorWorldRotation(UE.FRotator(0, RotAmount * 30 * UE.UGameplayStatics.GetWorldDeltaSeconds(self), 0), false, UE.FHitResult(), false)
            self.TarRot = self:GetOwner():K2_GetActorRotation()
        end
    end
end

---@private [RotSys] 允许更新旋转, 判断标准为角色拥有输入或处于实质的运动中
function AnimComp:CanUpdateMoveRot()
    return (not self:GetOwner():HasAnyRootMotion()) and ((self.IsMove and self.HasMoveInput) or self.Speed > 150)
end

---@private [RotSys] 使用"移动设置"中的当前"旋转速率曲线"来计算旋转速率; 将曲线与映射的速度结合使用, 可以对每个速度的转速进行高度控制; 如果相机快速旋转以获得更灵敏的旋转, 请提高速度
function AnimComp:CalcGroundRotRate()
    local MappedSpeed = self:GetMappedSpeed()
    local Rate = 0
    if MappedSpeed < 1 then
        Rate = Remap(MappedSpeed, 0, 1, 0, 4)
    elseif (MappedSpeed >= 1) and (MappedSpeed < 2) then
        Rate = Remap(MappedSpeed, 1, 2, 4, 5)
    elseif MappedSpeed >= 2 then
        Rate = Remap(MappedSpeed, 2, 3, 5, 20)
    end
    return Rate * UE.UKismetMathLibrary.MapRangeClamped(self.AimYawRate, 0, 300, 1, 3)
end

---@private [RotSys] 将角色的当前速度映射到配置的移动速度，范围为0-3，0=停止，1=行走速度，2=跑步速度，3=冲刺速度。这允许您改变移动速度，但在计算中仍然使用映射的范围以获得一致的结果。
function AnimComp:GetMappedSpeed()
    if self.Speed > self.RunSpeed then
        return UE.UKismetMathLibrary.MapRangeClamped(self.Speed, self.RunSpeed, self.SprintSpeed, 2, 3)
    elseif self.Speed > self.WalkSpeed then
        return UE.UKismetMathLibrary.MapRangeClamped(self.Speed, self.WalkSpeed, self.RunSpeed, 1, 2)
    else
        return UE.UKismetMathLibrary.MapRangeClamped(self.Speed, 0, self.WalkSpeed, 0, 1)
    end
end

---@private [RotSys] 
---@param Tar UE.FRotator
---@param TarInterpSpeed number Const
---@param ActorGroundRotRate number Smooth
function AnimComp:SmoothChrRot(Tar, TarInterpSpeed, ActorInterpSpeed)
    self.TarRot = UE.UKismetMathLibrary.RInterpTo_Constant(self.TarRot, Tar, UE.UGameplayStatics.GetWorldDeltaSeconds(self), TarInterpSpeed)
    local Rot = UE.UKismetMathLibrary.RInterpTo(self:GetOwner():K2_GetActorRotation(), self.TarRot, UE.UGameplayStatics.GetWorldDeltaSeconds(self), ActorInterpSpeed)
    self:GetOwner():K2_SetActorRotation(Rot, false)
end

---@private [RotSys] 
---@param InAimYawMin number
---@param InAimYawMax number
---@param InterpSpeed number
function AnimComp:LimitRot(InAimYawMin, InAimYawMax, InterpSpeed)
    -- 比较鼠标旋转和当前人物旋转
    local RotDelta = UE.UKismetMathLibrary.NormalizedDeltaRotator(self:GetOwner():GetControlRotation(), self:GetOwner():K2_GetActorRotation())
    if not UE.UKismetMathLibrary.InRange_FloatFloat(RotDelta.Yaw, InAimYawMin, InAimYawMax) then
        -- 旋转角度: 向右转就用Max这个, 向左转就用Min这个, 让他一直转到要求的控制旋转的边界
        local Yaw = RotDelta.Yaw > 0 and (self:GetOwner():GetControlRotation().Yaw + InAimYawMax) or (self:GetOwner():GetControlRotation().Yaw + InAimYawMin)
        self:SmoothChrRot(UE.FRotator(0, Yaw, 0) , 0, InterpSpeed)
    end
end

---@private [RotSys] 
function AnimComp:UpdateAirRot()
    if self.RotMode ~= ERotMode.AimDir then
        self:SmoothChrRot(UE.FRotator(0, self.InAirRot.Yaw, 0), 0, 5)
    else
        self:SmoothChrRot(UE.FRotator(0, self:GetOwner():GetControlRotation(), 0), 0, 15)
        self.InAirRot = self:GetOwner():K2_GetActorRotation()
    end
end

function AnimComp:GetTarMoveSetting()
    if self.RotMode == ERotMode.VelDir then
        if self.Stance == EStance.Stand then
            return {175, 375, 650}
        elseif self.Stance == EStance.Crouch then
            return {150, 200, 300}
        end
    elseif self.RotMode == ERotMode.LookDir then
        if self.Stance == EStance.Stand then
            return {175, 375, 650}
        elseif self.Stance == EStance.Crouch then
            return {150, 200, 300}
        end
    elseif self.RotMode == ERotMode.AimDir then
        if self.Stance == EStance.Stand then
            return {175, 375, 650}
        elseif self.Stance == EStance.Crouch then
            return {150, 200, 300}
        end
    end
    return {175, 375, 650}
end

function AnimComp:GetAnimCurveVal(CurveName)
    if UE.UKismetSystemLibrary.IsValid(self.MainAnimInst) then
        self.MainAnimInst:GetCurveValue(CurveName)
    else
        return 0
    end
end


return AnimComp
