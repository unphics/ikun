
---
---@brief Lich一技能, 近战
---@author zys
---@data Mon Apr 07 2025 01:09:03 GMT+0800 (中国标准时间)
---

---@class GA_Lich_Skill_01: GA_IkunBase
local GA_Lich_Skill_01 = UnLua.Class('Ikun/Blueprint/GAS/GA_IkunBase')

function GA_Lich_Skill_01:OnActivateAbility()
    self.Super.OnActivateAbility(self)

    ---@type UATPlayMtgAndWaitEvent
    local AT = UE.UATPlayMtgAndWaitEvent.PlayMtgAndWaitEvent(self, 'task name',
        self.MtgTwice, UE.FGameplayTagContainer(), 1, '', false, 1)
    AT.OnBlendOut:Add(self, self.OnCompleted)
    AT.OnCompleted:Add(self, self.OnCompleted)
    AT.OnInterrupted:Add(self, self.OnCancelled)
    AT.OnCancelled:Add(self, self.OnCancelled)
    AT.EventReceived:Add(self, self.OnEventReceived)
    AT:ReadyForActivation()
    self:RefUObject('AT', AT)
end

function GA_Lich_Skill_01:OnEventReceived(EventTag, EventData)
    local OwnerActor = self:GetAvatarActorFromActorInfo() ---@type BP_ChrBase
    if net_util.is_client(OwnerActor) then
        return
    end
    if EventTag.TagName ~= UE.UIkunFnLib.RequestGameplayTag('Chr.Skill.Hit.01').TagName then
        return
    end

    local TA = actor_util.spawn_always(OwnerActor, self.TargetActorClass, OwnerActor:GetTransform())
    -- local AT =  UE.UAbilityTask_WaitTargetData.WaitTargetDataUsingActor(self, '', 
    --     UE.EGameplayTargetingConfirmation.Custom, TA)
    -- AT.ValidData:Add(self, self.OnTAValidData)
    -- AT:ReadyForActivation()
    -- self.AT = AT
    -- self.TA = TA

    self:WaitTargetData_Tmp(TA)
end

function GA_Lich_Skill_01:OnTAValidData(Data, EventTag)
    local ActorArray = UE.UAbilitySystemBlueprintLibrary.GetAllActorsFromTargetData(Data)
    local TargetActor = nil
    for i = 1, ActorArray:Length() do
        local Actor = ActorArray:Get(i)
        if Actor:IsA(UE.AGameplayAbilityTargetActor) then
            TargetActor = Actor
            ActorArray:Remove(Actor)
        end
    end
    local OwnerActor = self:GetAvatarActorFromActorInfo() ---@type BP_ChrBase
    for i = 1, ActorArray:Length() do
        local Actor = ActorArray:Get(i)
        if Actor ~= OwnerActor and Actor.GetRole and Actor:GetRole() and OwnerActor:GetRole():IsEnemy(Actor:GetRole()) then
            local EffectContextHandle = self:GetContextFromOwner(Data)
            Actor:GetAbilitySystemComponent():BP_ApplyGameplayEffectToSelf(self.GameplayEffectClass, 1, EffectContextHandle)
        end
    end
end

function GA_Lich_Skill_01:OnCompleted()
    self:GASuccess()
end

function GA_Lich_Skill_01:OnCancelled()
    self:GAFail()
end

return GA_Lich_Skill_01