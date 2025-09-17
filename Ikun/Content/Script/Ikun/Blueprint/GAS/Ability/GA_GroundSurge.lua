
---
---@brief   地面浪涌的Ability
---@author  zys
---@data    Sun Sep 14 2025 14:34:11 GMT+0800 (中国标准时间)
---

local EnhInput = require('Ikun/Module/Input/EnhInput')
local InputMgr = require("Ikun/Module/Input/InputMgr")

---@class GA_GroundSurge: GA_IkunBase
local GA_GroundSurge = UnLua.Class('Ikun/Blueprint/GAS/GA_IkunBase')

---@override
function GA_GroundSurge:K2_ActivateAbilityFromEvent(Payload)
    self:GAInitData()
    if net_util.is_server(self) then
        local config = Payload.OptionalObject.SkillConfig ---@as SkillConfig
        self.SkillConfig = config

        local animKey = config.AbilityAnims[1]
        self.MtgEquip = self.AvatarLua.AnimComp.AnimMtg:Find(animKey)
        self:S2C_PlayEquipMtg(self.MtgEquip)

        local tagMax = UE.UIkunFnLib.RequestGameplayTag('Skill.Action.Charge.Max')
        local chargeTask = UE.UAbilityTask_WaitGameplayEvent.WaitGameplayEvent(self, tagMax, nil, true, true)
        chargeTask.EventReceived:Add(self, self.OnChargeMax)
        chargeTask:ReadyForActivation()
        self:RefTask(chargeTask)
    else
        self.DrawPower = InputMgr.BorrowInputPower(self)
        InputMgr.RegisterInputAction(self.DrawPower, EnhInput.IADef.IA_MouseLeftDown, EnhInput.TriggerEvent.Completed, self.OnMouseLeftDownCompleted)
    end
end

---@override
function GA_GroundSurge:K2_OnEndAbility(WasCancelled)
    InputMgr.UnregisterInputAction(self.DrawPower)
    InputMgr.ReliquishInputPower(self.DrawPower)
    self.Super.K2_OnEndAbility(self, WasCancelled)
end

---@private
function GA_GroundSurge:S2C_PlayEquipMtg_RPC(Mtg)
    ---@type UATPlayMtgAndWaitEvent
    local at = UE.UATPlayMtgAndWaitEvent.PlayMtgAndWaitEvent(self, 'task name', 
        Mtg, UE.FGameplayTagContainer(),  1 , '', false, 1.0)
    at.OnBlendOut:Add(self, self.OnCompleted)
    at.OnCompleted:Add(self, self.OnCompleted)
    at.OnInterrupted:Add(self, self.OnCancelled)
    at.OnCancelled:Add(self, self.OnCancelled)
    at:ReadyForActivation()
    self:RefTask(at)
end

---@private
function GA_GroundSurge:OnCompleted()
    self:GASuccess()
end

---@private
function GA_GroundSurge:OnCancelled()
    self:GAFail()
end

---@private [Server]
function GA_GroundSurge:OnChargeMax()
    local at = UE.UAbilityTask_Repeat.RepeatAction(self, 0.5, 99)
    at.OnPerformAction:Add(self, self.OnChargeRepeat)
    at:ReadyForActivation()
    self:RefTask(at)
    self.BeamAT = at
end

function GA_GroundSurge:OnMouseLeftDownCompleted()
    self:C2S_KeyRelease()
end

function GA_GroundSurge:C2S_KeyRelease_RPC()
    self:S2C_OnKeyRelease()
end

function GA_GroundSurge:S2C_OnKeyRelease_RPC()
    self:MontageJumpToSection('Anim_End')
    if self.BeamAT then
        self.BeamAT:EndTask()
    end
end

function GA_GroundSurge:OnChargeRepeat()
    local avatar = self:GetAvatarActorFromActorInfo()
    local taKey = self.SkillConfig.TargetActors[1]
    local taName = MdMgr.ConfigMgr:GetConfig('TargetActor')[taKey].TargetActorTemplate
    local taClass = UE.UClass.Load('/Game/Ikun/Blueprint/GAS/TargetActor/'..taName..'.'..taName..'_C')
    local ta = actor_util.spawn_always(avatar, taClass, avatar:GetTransform()) ---@as TA_IkunBase
    local context = self:MakeTargetActorContext()

    local GEName = self.SkillConfig.SkillEffects[1]
    local GEClass = gas_util.find_effect_class(GEName)
    context.EffectSpecHandle = self:MakeOutgoingGameplayEffectSpec(GEClass)
    ta:InitTargetActor(context)
    
    local at = UE.UAbilityTask_WaitTargetData.WaitTargetDataUsingActor(self, '', UE.EGameplayTargetingConfirmation.UserConfirmed, ta)
    at:ReadyForActivation()
    self:RefTask(at)
end

return GA_GroundSurge