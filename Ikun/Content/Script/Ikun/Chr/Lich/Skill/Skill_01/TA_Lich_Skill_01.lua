--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class TA_Lich_Skill_01: TA_Lich_Skill_01_C
local M = UnLua.Class('Ikun/Blueprint/GAS/TargetActor/TA_IkunBase')

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

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

function M:OnPostStartTargeting(Ability)
    self:ConfirmTargeting()
end

function M:OnPreConfirmTargetingAndContinue()
    self.Super.OnPreConfirmTargetingAndContinue(self)
    
    local OverlappingActors = UE.TArray(UE.AActor)
    self.Collision:GetOverlappingActors(OverlappingActors)
    
    local TargetDataHandle = UE.UAbilitySystemBlueprintLibrary.AbilityTargetDataFromActorArray(OverlappingActors, false)
    self.OwningAbility:RefUStruct(TargetDataHandle)
    -- self:BrostcastTargetData(UE.FGameplayAbilityTargetDataHandle())
    self:Multicast_DrawDebug()
    self:BrostcastTargetData(TargetDataHandle)
end

function M:Multicast_DrawDebug_RPC()
    UE.UKismetSystemLibrary.DrawDebugSphere(self, self.Collision:K2_GetComponentLocation(), self.Collision:GetScaledSphereRadius(), 12, UE.FLinearColor(0, 0, 1), 1.5, 4)
end

return M
