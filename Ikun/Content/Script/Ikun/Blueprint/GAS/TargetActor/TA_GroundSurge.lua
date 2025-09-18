
---
---@brief   地面浪涌的TargetActor
---@author  zys
---@data    Wed Sep 17 2025 20:16:36 GMT+0800 (中国标准时间)
---

---@class TA_GroundSurge: TA_IkunBase
local TA_GroundSurge = UnLua.Class('Ikun/Blueprint/GAS/TargetActor/TA_IkunBase')

---@override
function TA_GroundSurge:InitTargetActor(Context)
    self.Super.InitTargetActor(self, Context)
    
    local config = self.TargetActorContext.TargetActorConfig
    self.TotalDistance = config.Params.TotalDistance
    self.StepLength = config.Params.StepLength
    self.TotalTime = config.Params.TotalTime

    local collision = self.Collision ---@as UBoxComponent
    collision:K2_SetRelativeTransform(UE.FTransform(), false, UE.FHitResult(), false)
    local boxExtent = collision.BoxExtent
    self:S2C_SetBoxExtent(UE.FVector(self.StepLength, boxExtent.Y, boxExtent.Z))

    self.TotalStepNum = self.TotalDistance / self.StepLength
    self.TimerInterval = self.TotalTime / self.TotalStepNum
    self.StepCount = 0
    self.TimerHandle = async_util.timer(self, self.OnSurgePass, self.TimerInterval, true)

    self.IgnoreActor = {}
end

---@override
function TA_GroundSurge:ReceiveEndPlay()
    async_util.clear_timer(self, self.TimerHandle)
end

---@override
function TA_GroundSurge:OnPostStartTargeting(Ability)
    -- self:ConfirmTargeting()
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
        if not self.IgnoreActor[actor] and rolelib.is_valid_enemy(actor, context.OwnerAvatar) then
            for i, effectInfo in ipairs(context.AbilityEffectInfos) do
                local handle, obj = gas_util.make_effect_context_ex(context.OwnerAvatar)
                if handle and obj then
                    obj.OptEffectContext = {
                        SkillConfig = context.SkillConfig
                    }
                    actor:GetAbilitySystemComponent():BP_ApplyGameplayEffectToSelf(effectInfo.EffectClass, 1, handle)
                end
            end
        end
        self.IgnoreActor[actor] = 1
    end
end

---@private 浪涌渡过
function TA_GroundSurge:OnSurgePass()
    self.StepCount = self.StepCount + 1
    if self.StepCount > self.TotalStepNum then
        self:SurgeEnd()
    end
    local collision = self.Collision ---@as UBoxComponent
    collision:K2_SetRelativeLocation(UE.FVector(self.StepLength * self.StepCount, 0, 0), false, UE.FHitResult(), true)
    self:ConfirmTargeting()
end

---@private 浪涌结束
function TA_GroundSurge:SurgeEnd()
    async_util.clear_timer(self, self.TimerHandle)
    self:K2_DestroyActor()
end

---@private
function TA_GroundSurge:S2C_SetBoxExtent_RPC(Extent)
    self.Collision:SetBoxExtent(Extent, true)
end

return TA_GroundSurge