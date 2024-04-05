
local BP_ChrBase = UE.UClass.Load('/Game/Ikun/Chr/Blueprint/BP_ChrBase.BP_ChrBase_C')
local EnhancedInput = require("UnLua.EnhancedInput")

---@class BP_IkunPC: BP_IkunPC_C
---@field OwnerChr BP_ChrBase
local BP_IkunPC = UnLua.Class()

-- function BP_IkunPC:Initialize(Initializer)
-- end

function BP_IkunPC:UserConstructionScript()
end

function BP_IkunPC:ReceiveBeginPlay()
    if self:HasAuthority() then
    else
        self:InitEnhancedInput()
        self:InitCamera()
    end
end

-- function BP_IkunPC:ReceiveEndPlay()
-- end

function BP_IkunPC:ReceiveTick(DeltaSeconds)
end

-- function BP_IkunPC:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function BP_IkunPC:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function BP_IkunPC:ReceiveActorEndOverlap(OtherActor)
-- end

function BP_IkunPC:ReceivePossess(PossessedPawn)
    if PossessedPawn:Cast(BP_ChrBase) then
        self.OwnerChr = PossessedPawn
    end
end

---@private
function BP_IkunPC:InitEnhancedInput()
    ---@type UEnhancedInputLocalPlayerSubsystem
    local EnhancedInputSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubSystemFromPlayerController(self, UE.UEnhancedInputLocalPlayerSubsystem)
    if EnhancedInputSystem then
        ---@type IMC_Test
        local IMC_Test = UE.UObject.Load('/Game/Ikun/Blueprint/Input/IMC/IMC_Test.IMC_Test')
        if IMC_Test and (not EnhancedInputSystem:HasMappingContext(IMC_Test)) then
            EnhancedInputSystem:AddMappingContext(IMC_Test, 100, UE.FModifyContextOptions())
        end

        ---@type IMC_Default
        local IMC_Default = UE.UObject.Load('/Game/Ikun/Blueprint/Input/IMC/IMC_Default.IMC_Default')
        if IMC_Default and (not EnhancedInputSystem:HasMappingContext(IMC_Default)) then
            EnhancedInputSystem:AddMappingContext(IMC_Default, 100, UE.FModifyContextOptions())
        end
    end
end

---@private
function BP_IkunPC:InitCamera()
    local SpawnParams = UE.FSpawnParamters()
    SpawnParams.CollisionHandling = UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn
    SpawnParams.Instigator = self:Cast(UE.APawn)
    local CameraClass = UE.UClass.Load('/Game/Ikun/Blueprint/Camera/BP_Camera.BP_Camera_C')
    local Transform = self:GetTransform()
    local AlwaysSpawn = UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn
    local Camera = self:GetWorld():SpawnActor(CameraClass, Transform, AlwaysSpawn, self, self, "")
    self:SetViewTargetWithBlend(Camera)
    Camera:K2_AttachToActor(self, nil, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, UE.EAttachmentRule.SnapToTarget, true)
end

EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Move.IA_Move', 'Triggered', 
    function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        local PC = SourceObj
        local Rot = PC:GetControlRotation()
        local YawRot = UE.FRotator(0, Rot.Yaw, 0)
        local Forward = YawRot:GetForwardVector()
        if PC.OwnerChr then
            PC.OwnerChr:MoveForwardBack(Forward, ActionValue.Y)
            PC.OwnerChr:MoveRightLeft(Forward, ActionValue.X)
        end
    end)
EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Look.IA_Look', 'Triggered', 
    function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        local PC = SourceObj
        PC:AddYawInput(ActionValue.X * 50 * UE.UGameplayStatics.GetWorldDeltaSeconds(PC))
        PC:AddPitchInput(ActionValue.Y * 50 * UE.UGameplayStatics.GetWorldDeltaSeconds(PC))
    end)


return BP_IkunPC

--[[
    UE.UEnhancedInputLibrary.Conv_InputActionValueToBool
    UE.UEnhancedInputLibrary.Conv_InputActionValueToAxis1D
    UE.UEnhancedInputLibrary.Conv_InputActionValueToAxis2D
    UE.UEnhancedInputLibrary.Conv_InputActionValueToAxis3D
]]

--[[
local EnhancedInput = require("UnLua.EnhancedInput")

EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Test.IA_Test', 'Triggered', 
    function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        log.warn('不知道为啥数值总是不对', ActionValue) -- UE.UEnhancedInputLibrary.Conv_InputActionValueToAxis2D(ActionValue)
    end)
EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Move.IA_Move', 'Triggered', 
    function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        log.warn('move input 好像数值挺对的', ActionValue.X, ActionValue.Y) -- UE.UEnhancedInputLibrary.Conv_InputActionValueToAxis2D(ActionValue)
    end)
EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Look.IA_Look', 'Triggered', 
    function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        log.warn('look input', ActionValue.X, ActionValue.Y) -- UE.UEnhancedInputLibrary.Conv_InputActionValueToAxis2D(ActionValue)
    end)
]]

