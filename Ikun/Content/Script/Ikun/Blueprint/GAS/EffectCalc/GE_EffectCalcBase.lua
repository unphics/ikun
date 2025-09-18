
---
---@brief   伤害计算基类
---@author  zys
---@data    Mon Jun 02 2025 01:42:51 GMT+0800 (中国标准时间)
---

---@class GE_EffectCalcBase: UIkunGEExecCalc
local GE_EffectCalcBase = UnLua.Class()

---@override
---@param InParams FGameplayEffectCustomExecutionParameters
---@param OutParams FGameplayEffectCustomExecutionOutput
function GE_EffectCalcBase:Execute(InParams, OutParams)
    local calcObj = gas_util.new_calc_obj()
    calcObj:InitEffectCalcData(InParams)
    local Ability = UE.UIkunFnLib.EffectContextGetAbility(calcObj.Spec.EffectContext)
    local optObj = UE.UIkunFnLib.GetEffectContextOpObj(calcObj.Spec.EffectContext)
    self:OnExecute(calcObj, Ability, calcObj.Spec.Def, optObj)

    -- OutParams = CalcObj.OutExecParams
    OutParams.OutputModifiers:Append( calcObj.OutExecParams.OutputModifiers)
end

---@protected
---@param CalcObj BP_EffectCalcObj_C
---@param Ability GA_IkunBase
---@param Effect BP_GEBase
---@param OptionObj UObject
function GE_EffectCalcBase:OnExecute(CalcObj, Ability, Effect, OptionObj)
end

return GE_EffectCalcBase