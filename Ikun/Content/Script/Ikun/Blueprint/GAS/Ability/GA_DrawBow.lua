
---
---@brief   拉弓射箭
---@author  zys
---@data    Fri Sep 05 2025 01:43:35 GMT+0800 (中国标准时间)
---

local EnhInput = require('Ikun/Module/Input/EnhInput')
local InputMgr = require("Ikun/Module/Input/InputMgr")

---@class GA_DrawBow: BP_AbilityBase
---@field bChargeMax boolean 是否满弓
---@field SkillConfig SkillConfig
local GA_DrawBow = UnLua.Class('Ikun/Blueprint/GAS/Ability/BP_AbilityBase')

---@override
function GA_DrawBow:K2_ActivateAbilityFromEvent(Payload)
    self:GAInitData()
    if net_util.is_server(self) then
        local config = Payload.OptionalObject.SkillConfig ---@type SkillConfig
        self.SkillConfig = config
        local animKey = config.AbilityAnims[1]
        self.MtgEquip = self.AvatarLua.AnimComp.AnimMtg:Find(animKey)
        self:S2C_PlayEquipMtg(self.MtgEquip)

        -- 相机切换到越肩视角
        local ctlr = self.AvatarLua:GetController()
        if ctlr and ctlr.CameraViewComp then
            ctlr.CameraViewComp:S2C_NewCameraViewModel('Aim')
        end

        -- 满弓
        local tagMax = UE.UIkunFnLib.RequestGameplayTag('Skill.Action.Charge.Max')
        local chargeTask = UE.UAbilityTask_WaitGameplayEvent.WaitGameplayEvent(self, tagMax, nil, true, true)
        chargeTask.EventReceived:Add(self, self.OnChargeMax)
        chargeTask:ReadyForActivation()
        self:RefTask(chargeTask)
        
        -- 释放
        local tag = UE.UIkunFnLib.RequestGameplayTag('Skill.Action.Release')
        local shootTask = UE.UAbilityTask_WaitGameplayEvent.WaitGameplayEvent(self, tag, nil, true, true)
        shootTask.EventReceived:Add(self, self.OnAnimShoot)
        shootTask:ReadyForActivation()
        self:RefTask(shootTask)
    else
        gas_util.add_loose_tag(self:GetAvatarActorFromActorInfo(), 'Role.State.CantMove')
        self.DrawPower = InputMgr.BorrowInputPower(self)
        InputMgr.RegisterInputAction(self.DrawPower, EnhInput.IADef.IA_MouseLeftDown, EnhInput.TriggerEvent.Completed, self.OnMouseLeftDownCompleted)
    end
end

---@override
function GA_DrawBow:K2_OnEndAbility(WasCancelled)
    self:GetAvatarActorFromActorInfo().AnimComp:IntoFight()
    if net_util.is_client(self) then
        gas_util.remove_loose_tag(self:GetAvatarActorFromActorInfo(), 'Role.State.CantMove')
    end
    InputMgr.UnregisterInputAction(self.DrawPower)
    InputMgr.ReliquishInputPower(self.DrawPower)
    self.Super.K2_OnEndAbility(self, WasCancelled)
end

---@private
function GA_DrawBow:S2C_PlayEquipMtg_RPC(Mtg)
    self:GetAvatarActorFromActorInfo().AnimComp:IntoAim()
    self.bChargeMax = false

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
function GA_DrawBow:OnCompleted()
    self:GASuccess()
end

---@private
function GA_DrawBow:OnCancelled()
    self:GAFail()
end

---@private
function GA_DrawBow:OnMouseLeftDownCompleted()
    self:C2S_DrawRelease()
end

---@private
function GA_DrawBow:OnChargeMax()
    self.bChargeMax = true
end

---@private
function GA_DrawBow:C2S_DrawRelease_RPC()
    self:S2C_OnDrawRelease()
end

---@private
function GA_DrawBow:S2C_OnDrawRelease_RPC()
    self:MontageJumpToSection('Aim_End')

    ---@step 相机从越肩视角切换回普通视角
    if net_util.is_server(self) then
        local ctlr = self.AvatarLua:GetController()
        if ctlr and ctlr.CameraViewComp then
            ctlr.CameraViewComp:S2C_NewCameraViewModel('Normal')
        end
    end
end

---@private
function GA_DrawBow:OnAnimShoot()
    if not self.bChargeMax then
        return
    end
    local shootLoc = self.AvatarLua.Bow:GetSocketLocation('Bow_String')
    local upDir = self.AvatarLua:GetActorUpVector()
    shootLoc = shootLoc + upDir * 10
    local shootRot = self.AvatarLua:GetControlRotation()
    local shootTansform = UE.FTransform(shootRot:ToQuat(), shootLoc)
    local ArrowClass = UE.UClass.Load('/Game/Ikun/Chr/Archer/BP_Arrow.BP_Arrow_C')
    local arrow = actor_util.spawn_always(self.AvatarLua, ArrowClass, shootTansform) ---@type BP_ProjectileBase
    ---@class AbilityContext
    local AbilityContext = {
        Ability = self,
        Avatar = self:GetAvatarActorFromActorInfo(),
        SkillConfig = self.SkillConfig,
    }
    arrow:InitProjectile(AbilityContext)
end

return GA_DrawBow