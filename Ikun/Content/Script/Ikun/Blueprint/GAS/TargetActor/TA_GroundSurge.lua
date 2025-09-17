
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
    for i = 1, Actors:Length() do
        local actor = Actors:Get(i)
        ---@todo 回家写
    end
end

return TA_GroundSurge