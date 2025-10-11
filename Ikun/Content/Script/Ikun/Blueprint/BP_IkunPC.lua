
---
---@brief   PlayerController
---@author  zys
---@data    Sat Jul 19 2025 17:23:24 GMT+0800 (中国标准时间)
---

local EnhInput = require('Ikun/Module/Input/EnhInput')
local InputMgr = require("Ikun/Module/Input/InputMgr")

---@class BP_IkunPC: BP_IkunPC_C
---@field OwnerChr BP_ChrBase
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
    log.info(log.key.ueinit..' BP_IkunPC:ReceiveBeginPlay() svr:'..tostring(net_util.is_server(self)))
    self.Overridden.ReceiveBeginPlay(self)
    if net_util.is_client(self) then
        self:InitInputSystem()
        async_util.delay(self, 1, self.InitPlayerInput, self)
    else
        local trigger = UE.FAbilityTriggerData()
        trigger.TriggerTag = UE.UIkunFnLib.RequestGameplayTag('Skill.Action.Charge.Max')
    end


    -- if net_util.is_client(self) then
    --     local EnhancedInput = require("UnLua.EnhancedInput")
    --     local actionPath = '/Game/Developers/zys/EnhancedInput/IA_Test.IA_Test'
    --     EnhancedInput.BindAction(self, actionPath, 'Started', function()
    --         log.error('qqqqqqqqqqq')
    --     end)
    --     UE.UIkunFnLib.ReplaceInputs(self, self.InputComponent)
    -- end
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
    log.info('BP_IkunPC:InitInputSystem()')
    EnhInput.InitByPlayerController(self)
    EnhInput.AddIMC(UE.UObject.Load(EnhInput.IMCDef.IMC_Base))

end
EnhInput.BindActions(BP_IkunPC)

---@private [Input]
function BP_IkunPC:InitPlayerInput()
    local inputPower = InputMgr.ObtainInputPower(self)
    InputMgr.RegisterInputAction(inputPower, EnhInput.IADef.IA_Move, EnhInput.TriggerEvent.Triggered, self.OnMoveInput)
    InputMgr.RegisterInputAction(inputPower, EnhInput.IADef.IA_Look, EnhInput.TriggerEvent.Triggered, self.OnLookInput)
    InputMgr.RegisterInputAction(inputPower, EnhInput.IADef.IA_MouseLeftDown, EnhInput.TriggerEvent.Started, self.OnMouseLeftStarted)
    InputMgr.RegisterInputAction(inputPower, EnhInput.IADef.IA_MouseLeftDown, EnhInput.TriggerEvent.Completed, self.OnMouseLeftCompleted)
    InputMgr.RegisterInputAction(inputPower, EnhInput.IADef.IA_MouseLeftDown, EnhInput.TriggerEvent.Triggered, self.OnMouseLeftTriggered)
    InputMgr.RegisterInputAction(inputPower, EnhInput.IADef.IA_BlankSpace, EnhInput.TriggerEvent.Started, self.OnJumpStarted)
end

---@private [Input]
function BP_IkunPC:OnMoveInput(ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    local rot = self:GetControlRotation()
    local yawRot = UE.FRotator(0, rot.Yaw, 0)
    local forward = yawRot:GetForwardVector()
    if self.OwnerChr and not gas_util.has_loose_tag(self.OwnerChr, 'Role.State.CantMove') then
        self.OwnerChr:MoveForwardBack(forward, ActionValue.Y)
        self.OwnerChr:MoveRightLeft(forward, ActionValue.X)
    end
end

---@private [Input]
function BP_IkunPC:OnLookInput(ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    self:AddYawInput(-ActionValue.X)
    self:AddPitchInput(ActionValue.Y)
end

function BP_IkunPC:OnJumpStarted(ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    if obj_util.is_valid(self.OwnerChr) then
        self.OwnerChr:C2S_Jump()
    end
end

---@private [Input]
function BP_IkunPC:OnMouseLeftStarted(ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    if not obj_util.is_valid(self.OwnerChr) then
        return
    end
    ---@rule 玩家和平状态下的第一次左键点击先入战, 下一次再考虑执行左键绑定的技能等
    if not self.OwnerChr.InFightComp:CheckInFight() then
        self.OwnerChr.InFightComp:C2S_FallInFight()
        return
    end
    self.OwnerChr.InFightComp:C2S_FallInFight()
    self.OwnerChr:C2S_LeftStart()
end

return BP_IkunPC