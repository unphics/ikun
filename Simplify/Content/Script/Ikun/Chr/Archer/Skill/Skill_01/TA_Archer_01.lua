
---
---@brief   弓箭手技能1的TargetActor
---

---@class TA_Archer_01: TA_IkunBase
local TA_Archer_01 = UnLua.Class('Ikun/Blueprint/GAS/TA_IkunBase')

-- function TA_Archer_01:Initialize(Initializer)
-- end

-- function TA_Archer_01:UserConstructionScript()
-- end

-- function TA_Archer_01:ReceiveBeginPlay()
-- end

-- function TA_Archer_01:ReceiveEndPlay()
-- end

-- function TA_Archer_01:ReceiveTick(DeltaSeconds)
-- end

-- function TA_Archer_01:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function TA_Archer_01:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function TA_Archer_01:ReceiveActorEndOverlap(OtherActor)
-- end

---@override
function TA_Archer_01:OnPostStartTargeting(Ability)
    self:ConfirmTargeting()
end

---@override
function TA_Archer_01:OnPreConfirmTargetingAndContinue()
    self.Super.OnPreConfirmTargetingAndContinue(self)

    local overlappingActors = UE.TArray(UE.AActor)
    self.Collision:GetOverlappingActors(overlappingActors)
    
    local targetDataHandle = UE.UAbilitySystemBlueprintLibrary.AbilityTargetDataFromActorArray(overlappingActors, false)
    self:BrostcastTargetData(targetDataHandle)
end

return TA_Archer_01