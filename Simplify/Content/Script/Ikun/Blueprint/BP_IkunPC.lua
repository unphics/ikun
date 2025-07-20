
---
---@brief   PlayerController
---@author  zys
---@data    Sat Jul 19 2025 17:23:24 GMT+0800 (中国标准时间)
---

local EnhInput = require('Ikun/Module/Input/EnhInput')

---@class BP_IkunPC: BP_IkunPC_C
local BP_IkunPC = UnLua.Class()

-- function BP_IkunPC:Initialize(Initializer)
-- end

-- function BP_IkunPC:UserConstructionScript()
-- end

---@override
---@param PossessedPawn BP_ChrBase
function BP_IkunPC:ReceivePossess(PossessedPawn)
    if PossessedPawn.GetRole then
        self.OwnerChr = PossessedPawn
    end
end

---@override
function BP_IkunPC:ReceiveBeginPlay()
    log.log(log.key.ueinit..' BP_IkunPC:ReceiveBeginPlay() svr:'..tostring(net_util.is_server(self)))
    self.Overridden.ReceiveBeginPlay(self)
    if net_util.is_client(self) then
        self:InitInputSystem()
    end
end

-- function BP_IkunPC:ReceiveEndPlay()
-- end

-- function BP_IkunPC:ReceiveTick(DeltaSeconds)
-- end

-- function BP_IkunPC:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function BP_IkunPC:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function BP_IkunPC:ReceiveActorEndOverlap(OtherActor)
-- end

---@private [Input]
function BP_IkunPC:InitInputSystem()
    log.log('BP_IkunPC:InitInputSystem()')
    EnhInput.InitByPlayerController(self)
    EnhInput.AddIMC(UE.UObject.Load(EnhInput.IMCDef.IMC_Base))
    EnhInput.RegisterInputAction(EnhInput.IADef.IA_Move, self, self.OnMoveInput)
    EnhInput.RegisterInputAction(EnhInput.IADef.IA_Look, self, self.OnLookInput)
end
EnhInput.BindActions(BP_IkunPC)

---@private [Input]
function BP_IkunPC:OnMoveInput(ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    local rot = self:GetControlRotation()
    local yawRot = UE.FRotator(0, rot.Yaw, 0)
    local forward = yawRot:GetForwardVector()
    if self.OwnerChr then
        self.OwnerChr:MoveForwardBack(forward, ActionValue.Y)
        self.OwnerChr:MoveRightLeft(forward, ActionValue.X)
    end
end

---@private [Input]
function BP_IkunPC:OnLookInput(ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    self:AddYawInput(-ActionValue.X)
    self:AddPitchInput(ActionValue.Y)
end

return BP_IkunPC