
local BP_ChrBase = UE.UClass.Load('/Game/Ikun/Chr/Blueprint/BP_ChrBase.BP_ChrBase_C')

---@class BP_IkunPC: BP_IkunPC_C
---@field OwnerChr BP_ChrBase
local BP_IkunPC = UnLua.Class()

-- function BP_IkunPC:Initialize(Initializer)
-- end

function BP_IkunPC:UserConstructionScript()
end

function BP_IkunPC:ReceiveBeginPlay()
    if self:HasAuthority() then
        log.log("GamePlay PlayerController ReceiveBeginPlay Server")
        world_util.GameWorld = self
        net_util.b_svr = true
    else
        log.log("GamePlay PlayerController ReceiveBeginPlay Client")
        net_util.b_svr = false
        world_util.GameWorld = self
        self:InitEnhancedInput()
        -- self:InitCamera()
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


function BP_IkunPC:MouseLeft_Server_RPC()
    self.OwnerChr:NormalAttack()
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

local EnhancedInput = require("UnLua.EnhancedInput")
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
EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_MouseL.IA_MouseL', 'Started', 
    function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        local PC = SourceObj
        PC:MouseLeft_Server()
    end)
EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Jump.IA_Jump', 'Started', 
    function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        local PC = SourceObj
        if PC.OwnerChr then
            PC.OwnerChr:ChrJump()
        end
    end)
EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Crouch.IA_Crouch', 'Started', 
    function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        local PC = SourceObj
        if PC.OwnerChr then
            PC.OwnerChr:ChrCrouch()
        end
    end)
EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Sprint.IA_Sprint', 'Started', 
    function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        local PC = SourceObj
        if PC.OwnerChr then
            PC.OwnerChr:ChrSprint(true)
        end
    end)
EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Sprint.IA_Sprint', 'Completed', 
    function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        local PC = SourceObj
        if PC.OwnerChr then
            PC.OwnerChr:ChrSprint(false)
        end
    end)


return BP_IkunPC