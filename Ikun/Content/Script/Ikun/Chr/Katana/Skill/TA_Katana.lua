--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class TA_Katana : TA_Katana_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

function M:UserConstructionScript()
    self.CollideActors = UE.TArray(UE.AActor)
end

-- function M:ReceiveBeginPlay()
-- end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

function M:OnStartTargeting(Ability)
    
end

return M
