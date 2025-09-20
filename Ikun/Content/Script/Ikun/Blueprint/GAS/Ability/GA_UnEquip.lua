
---
---@brief   退出战斗状态
---@author  zys
---@data    Tue Sep 02 2025 23:47:54 GMT+0800 (中国标准时间)
---

---@class GA_UnEquip: BP_AbilityBase
local GA_UnEquip = UnLua.Class('Ikun/Blueprint/GAS/Ability/BP_AbilityBase')

---@override
---@param Payload FGameplayEventData
function GA_UnEquip:K2_ActivateAbilityFromEvent(Payload)
    self:GAInitData()
    if net_util.is_server(self) then
        local config = Payload.OptionalObject.SkillConfig ---@type SkillConfig
        local animKey = config.AbilityAnims[1]
        self.MtgUnEquip = self.AvatarLua.AnimComp.AnimMtg:Find(animKey)
        self:S2C_PlayUnEquipMtg(self.MtgUnEquip)
    end
end

---@override
function GA_UnEquip:K2_OnEndAbility(WasCancelled)
    local chr = self:GetAvatarActorFromActorInfo()
    local animComp = chr.AnimComp ---@as AnimComp
    -- animComp:IntoPeace()
    animComp:LinkNewClassLayer('Peace')
    self.Super.K2_OnEndAbility(self, WasCancelled)
end

---@private
function GA_UnEquip:S2C_PlayUnEquipMtg_RPC(Mtg)
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
function GA_UnEquip:OnCompleted()
    self:GASuccess()
end

---@private
function GA_UnEquip:OnCancelled()
    self:GAFail()
end

return GA_UnEquip