--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class TA_GroundSurge: TA_IkunBase
local TA_GroundSurge = UnLua.Class('Ikun/Blueprint/GAS/TA_IkunBase')

function TA_GroundSurge:OnPostStartTargeting(Ability)
    self:ConfirmTargeting()
end

function TA_GroundSurge:OnPreConfirmTargetingAndContinue()
    self.Super.OnPreConfirmTargetingAndContinue(self)
    
    local OverlappingActors = UE.TArray(UE.AActor)
    self.Collision:GetOverlappingActors(OverlappingActors)

    self:ApplyEffect(OverlappingActors)
    
    local TargetDataHandle = UE.UAbilitySystemBlueprintLibrary.AbilityTargetDataFromActorArray(OverlappingActors, false)
    self.OwningAbility:RefUStruct(TargetDataHandle)
    -- self:BrostcastTargetData(UE.FGameplayAbilityTargetDataHandle())
    -- self:Multicast_DrawDebug()
    self:BrostcastTargetData(TargetDataHandle)
end

function TA_GroundSurge:ApplyEffect(Actors)
    
end

function TA_GroundSurge:InitTargetActor(SkillConfig)
    self.SkillConfig = SkillConfig
end

return TA_GroundSurge