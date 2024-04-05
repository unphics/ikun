--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BP_CameraMgr_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
    self.PlayerController = UE.UGameplayStatics.GetPlayerController(self, 0)
end

function M:ReceiveEndPlay()
end

-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

---@private
---@notice 此函数在cpp中为<bool(AActor, out FVector, out FRotator, out number)>, 但是在lua中要3个out参数要在第一个返回值bool后返回出去
---@param CameraTarget AActor
---@return boolean, FVector, FRotator, number
function M:BlueprintUpdateCamera(CameraTarget)
    if CameraTarget and self.PlayerController then
        local Rot = self.PlayerController:GetControlRotation()
        local Loc = CameraTarget:K2_GetActorLocation()
        Loc = Loc + (Rot:GetForwardVector() * -380)
        Loc = Loc + Rot:GetRightVector() * 1
        Loc = Loc + Rot:GetUpVector() * 100
        return true, Loc, Rot, 90
    end
    return false
end

return M
