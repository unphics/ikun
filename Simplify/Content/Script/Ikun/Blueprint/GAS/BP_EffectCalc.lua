
---
---@brief 伤害计算核心逻辑
---@author zys
---@data Mon Jun 02 2025 01:42:51 GMT+0800 (中国标准时间)
---

---@class BP_EffectCalc: BP_EffectCalc_C
local BP_EffectCalc = UnLua.Class()

function BP_EffectCalc:OnCalcEffectData()
    local value = self:ReadAttrValue('Health', false)
    log.dev('BP_EffectCalc:OnCalcEffectData', value)
    local ContextHandle = self.Spec.EffectContext
    local Ability = UE.UIkunFnLib.EffectContextGetAbility(self.Spec.EffectContext)
    self:ModiAttrValue('Health', -3, UE.EGameplayModOp.Additive)
end

return BP_EffectCalc