
local EGait = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/Gait.Gait')
local EMoveDir = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/MoveDir.MoveDir')
local EMoveState = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/MoveState.MoveState')
local ERotMode = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/RotMode.RotMode')
local EStance = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/Stance.Stance')
local EViewModel = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/ViewModel.ViewModel')

---@class BP_ChrBase: BP_ChrBase_C
---@field FightComp BP_FightComp
---@field Role Role
local BP_ChrBase = UnLua.Class()

-- function BP_ChrBase:Initialize(Initializer)
-- end

-- function BP_ChrBase:UserConstructionScript()
-- end

function BP_ChrBase:ReceiveBeginPlay()
    async_util.timer(self,  function()
        self.MsgBusComp:TriggerEvent('ChrInitData')
    end, 1, false)
    async_util.timer(self, function()
        self.MsgBusComp:TriggerEvent('ChrInitDisplay')
    end, 2, false)
end

-- function BP_ChrBase:ReceiveEndPlay()
-- end

function BP_ChrBase:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds)
end

-- function BP_ChrBase:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function BP_ChrBase:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function BP_ChrBase:ReceiveActorEndOverlap(OtherActor)
-- end

---@public 返回chr的motion数据
function BP_ChrBase:BPIGetEssentialVal()
    return self.AnimComp:GetEssentialVal()
end

function BP_ChrBase:BPIGetChrState()
    return self.AnimComp:GetChrState()
end

---@public [Input] 前后移动输入
---@param Fwd FVector
---@param Val number
BP_ChrBase.MoveForwardBack = function(self, Fwd, Val)
    -- self.Overridden.MoveForwardBack(self, Fwd, Val)
    local Rot = self:GetControlRotation()
    local YawRot = UE.FRotator(0, Rot.Yaw, 0)
    local Forward = YawRot:GetForwardVector()
    self:AddMovementInput(Forward, Val, false)
end

---@public [Input] 左右移动输入
---@param Fwd FVector
---@param Val number
BP_ChrBase.MoveRightLeft = function(self, Fwd, Val)
    -- self.Overridden.MoveRightLeft(self, Fwd, Val)
    local Rot = self:GetControlRotation()
    local YawRot = UE.FRotator(0, Rot.Yaw, 0)
    local Right = YawRot:GetRightVector()
    self:AddMovementInput(Right, Val, false)
end

---@public [Input] 跳跃
BP_ChrBase.ChrJump = function(self)
    self:Jump()
    self.AnimComp.MainAnimInst.Jumped = true
end

---@public [Input] 蹲伏
BP_ChrBase.ChrCrouch = function(self)
    if not self.CharacterMovement:IsCrouching() then
        self:Crouch(true)
    else
        self:UnCrouch(true)
    end
end

---@public [Input] 冲刺
BP_ChrBase.ChrSprint = function(self, bSprint)
    if bSprint then
        self.AnimComp.Gait = EGait.Sprint
    else
        self.AnimComp.Gait = EGait.Run
    end
end

---@public [Input] [Server] 普攻
BP_ChrBase.NormalAttack = function(self)
    -- 主动入战
    self.FightComp:Equip()
    log.log('BP_ChrBase.NormalAttack')
end

return BP_ChrBase
