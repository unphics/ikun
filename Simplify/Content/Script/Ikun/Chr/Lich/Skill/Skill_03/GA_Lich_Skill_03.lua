
---
---@brief Lich三技能治疗术, 持续施法每秒恢复目标的生命值
---@author zys
---@data Tue Jun 10 2025 11:27:57 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class GA_Lich_Skill_03: GA_IkunBase
---@field HealedTime number
local GA_Lich_Skill_03 = UnLua.Class('Ikun/Blueprint/GAS/GA_IkunBase')

function GA_Lich_Skill_03:OnActivateAbility()
    self.Super.OnActivateAbility(self)

    ---@type UATPlayMtgAndWaitEvent
    local AT = UE.UATPlayMtgAndWaitEvent.PlayMtgAndWaitEvent(self, 'task name', 
        self.Mtg2Play, UE.FGameplayTagContainer(),  1.0 , 'Start', false, 1.0)
    AT.OnBlendOut:Add(self, self.OnCompleted)
    AT.OnCompleted:Add(self, self.OnCompleted)
    AT.OnInterrupted:Add(self, self.OnCancelled)
    AT.OnCancelled:Add(self, self.OnCancelled)
    AT.EventReceived:Add(self, self.OnEventReceived)
    AT:ReadyForActivation()
    self:RefUObject('AT', AT)

    self:CheckBlueprintCfg()
end

function GA_Lich_Skill_03:K2_OnEndAbility(WasCancelled)
    if net_util.is_server(self:GetAvatarActorFromActorInfo()) then
        async_util.clear_timer(self.AvatarLua, self.TimerHandle)
    end
    self.Super.K2_OnEndAbility(self, WasCancelled)
end

function GA_Lich_Skill_03:OnEventReceived(EventTag, EventData)
    if net_util.is_client(self.AvatarLua) then
        return
    end
    if EventTag.TagName == UE.UIkunFnLib.RequestGameplayTag('Chr.Skill.Hit.01').TagName then
        self.HealedTime = 0
        self.TimerHandle = async_util.timer(self.AvatarLua, function()self:TimerLoopCall() end, self.HealInterval, true)
    end
end

function GA_Lich_Skill_03:TimerLoopCall()
    self.HealedTime = self.HealedTime + self.HealInterval
    if (not self:GetHealTarget()) or (self.HealedTime >= self.MaxHealTime) then
        async_util.clear_timer(self.AvatarLua, self.TimerHandle)
        self:MontageJumpToSection('End')
        return
    end
    local EffectContextHandle = self:GetContextFromOwner(nil)
    self:GetHealTarget():GetAbilitySystemComponent():BP_ApplyGameplayEffectToSelf(self.GameplayEffectClass, 1, EffectContextHandle)
end

---@private 获取治疗目标
---@return BP_ChrBase
function GA_Lich_Skill_03:GetHealTarget()
    ---@todo 这里的Target肯定不是啥FightTarget
    local Target = self.AvatarLua:GetRole().BT.Blackboard:GetBBValue(BBKeyDef.SupportTarget)
    Target = Target.Avatar
    return Target
end

function GA_Lich_Skill_03:OnCompleted(EventTag, EventData)
    self:GASuccess()
end

function GA_Lich_Skill_03:OnCancelled(EventTag, EventData)
    self:GAFail()
end

---@private 检查技能的某些配置项正常
function GA_Lich_Skill_03:CheckBlueprintCfg()
    if self.MaxHealTime and self.MaxHealTime > 0 then
        return
    end
    if self.HealInterval and self.HealInterval > 0 then
        return
    end
    log.error('GA_Lich_Skill_03:CheckBlueprintCfg() 配置有问题!!!')
end

return GA_Lich_Skill_03