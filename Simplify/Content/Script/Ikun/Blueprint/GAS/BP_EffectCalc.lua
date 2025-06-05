
---
---@brief 伤害计算核心逻辑
---@author zys
---@data Mon Jun 02 2025 01:42:51 GMT+0800 (中国标准时间)
---

---@class BP_EffectCalc: BP_EffectCalc_C
local BP_EffectCalc = UnLua.Class()

function BP_EffectCalc:OnCalcEffectData()
    local ContextHandle = self.Spec.EffectContext
    local Ability = UE.UIkunFnLib.EffectContextGetAbility(self.Spec.EffectContext)

    ---@todo 思考一个整体的复杂的伤害计算公式
    
    local TargetPhysicalDefenseVal = self:ReadAttrValue('PhysicalDefense', false)
    local PercentPhysicalDefenseVal = math.log(TargetPhysicalDefenseVal) -- log的底数为nil的话默认是e
    
    local TargetHealthVal = self:ReadAttrValue('Health', false)
    log.dev('BP_EffectCalc:OnCalcEffectData', TargetHealthVal)


    self:ModiAttrValue('Health', -3, UE.EGameplayModOp.Additive)
end

return BP_EffectCalc