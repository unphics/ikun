
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

---@private [Client]
function BP_IkunPC:InitInputSystem()
    log.dev('BP_IkunPC:InitInputSystem()')
    EnhInput.InitByPlayerController(self)
    EnhInput.AddIMC(UE.UObject.Load(EnhInput.IMCDef.IMC_Move))

    local inputcomp = self.InputComponent ---@type UEnhancedInputComponent
    if inputcomp:Cast(UE.UEnhancedInputComponent) then
        UE.UIkunFnLib.BindAction(inputcomp, UE.UObject.Load(EnhInput.IADef.IA_Move), UE.ETriggerEvent.Started, self, 'eee')
    end
end

-- EnhInput.BindMove(BP_IkunPC)

function BP_IkunPC:eee()
    log.dev('eee')
end

function BP_IkunPC:qqq()
    BP_IkunPC.__UnLuaInputBindings = {}
end

return BP_IkunPC