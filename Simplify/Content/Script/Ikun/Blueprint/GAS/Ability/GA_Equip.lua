
---
---@brief   进入战斗状态
---@author  zys
---@data    Sun Aug 31 2025 12:17:18 GMT+0800 (中国标准时间)
---

---@class GA_Equip: GA_IkunBase
local GA_Equip = UnLua.Class('Ikun/Blueprint/GAS/GA_IkunBase')

---@override
function GA_Equip:OnActivateAbility()
    self.Super.OnActivateAbility(self)

    ---@type UATPlayMtgAndWaitEvent
    local at = UE.UATPlayMtgAndWaitEvent.PlayMtgAndWaitEvent(self, 'task name', 
        self.MtgEquip, UE.FGameplayTagContainer(),  1 , '', false, 1.0)
    at.OnBlendOut:Add(self, self.OnCompleted)
    at.OnCompleted:Add(self, self.OnCompleted)
    at.OnInterrupted:Add(self, self.OnCancelled)
    at.OnCancelled:Add(self, self.OnCancelled)
    at:ReadyForActivation()
    self:RefTask(at)
end

---@override
function GA_Equip:K2_OnEndAbility(WasCancelled)
    local chr = self:GetAvatarActorFromActorInfo()
    chr.AnimComp:IntoFight()
    self.Super.K2_OnEndAbility(self, WasCancelled)
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