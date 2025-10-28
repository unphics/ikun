
---
---@brief   进入战斗状态
---@author  zys
---@data    Sun Aug 31 2025 12:17:18 GMT+0800 (中国标准时间)
---

---@class GA_Equip: BP_AbilityBase
local GA_Equip = UnLua.Class('Ikun/Blueprint/GAS/Ability/BP_AbilityBase')

---@override
function GA_Equip:K2_ActivateAbilityFromEvent(Payload)
    self:GAInitData()
    if net_util.is_server(self) then
        local config = ConfigMgr:GetConfig('Skill')[Payload.OptionalObject.SkillId] ---@type SkillConfig
        local animKey = config.AbilityAnims[1]
        self.MtgEquip = self.AvatarLua.AnimComp.AnimMtg:Find(animKey)
        self:S2C_PlayEquipMtg(self.MtgEquip)
    end
end

---@override
function GA_Equip:K2_OnEndAbility(WasCancelled)
    local chr = self:GetAvatarActorFromActorInfo()
    local animComp = chr.AnimComp ---@as AnimComp
    animComp:LinkNewClassLayer('Fight')
    self.Super.K2_OnEndAbility(self, WasCancelled)
end

---@private
function GA_Equip:S2C_PlayEquipMtg_RPC(Mtg)
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
function GA_Equip:OnCompleted()
    self:GASuccess()
end

---@private
function GA_Equip:OnCancelled()
    self:GAFail()
end

return GA_Equip