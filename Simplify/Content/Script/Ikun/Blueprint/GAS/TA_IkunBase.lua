---
---
---
---

---@class TA_IkunBase: TA_IkunBase_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
    self.bDestroyOnConfirmation = false
end

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

function M:OnPreStartTargeting(Ability)
end

function M:OnPostStartTargeting(Ability)
end

function M:OnPreConfirmTargetingAndContinue()
    -- self:Multicast_DrawDebug()
end

function M:OnPostConfirmTargetingAndContinue()
end

return M
