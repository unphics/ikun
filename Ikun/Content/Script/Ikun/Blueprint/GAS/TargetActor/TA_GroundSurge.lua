
---
---@brief   地面浪涌的TargetActor
---@author  zys
---@data    Wed Sep 17 2025 20:16:36 GMT+0800 (中国标准时间)
---

---@class TA_GroundSurge: TA_IkunBase
local TA_GroundSurge = UnLua.Class('Ikun/Blueprint/GAS/TargetActor/TA_IkunBase')

---@override
function TA_GroundSurge:OnPostStartTargeting(Ability)
    self:ConfirmTargeting()
end

---@override
function TA_GroundSurge:OnPreConfirmTargetingAndContinue()
    self.Super.OnPreConfirmTargetingAndContinue(self)
    
    local OverlappingActors = UE.TArray(UE.AActor)
    self.Collision:GetOverlappingActors(OverlappingActors)

    -- local TargetDataHandle = UE.UAbilitySystemBlueprintLibrary.AbilityTargetDataFromActorArray(OverlappingActors, false)
    self:ApplyEffect(OverlappingActors)
end

---@private
---@param Actors TArray<AActor>
function TA_GroundSurge:ApplyEffect(Actors)
    local context = self.TargetActorContext
    for i = 1, Actors:Length() do
        local actor = Actors:Get(i) ---@as BP_ChrBase
        if rolelib.is_valid_enemy(actor, context.OwnerAvatar) then
            local handle, obj = gas_util.make_effect_context_ex(context.OwnerAvatar)
            if handle and obj then
                obj.OptEffectContext = {
                    SkillConfig = context.SkillConfig
                }
                actor:GetAbilitySystemComponent():BP_ApplyGameplayEffectToSelf(context.EffectClass, 1, handle)
            end
        end
    end
end

return TA_GroundSurge