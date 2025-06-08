
---
---@brief 伤害计算
---@author zys
---@data Mon Jun 02 2025 01:42:51 GMT+0800 (中国标准时间)
---

---@class GE_EffectCalcBase: GE_EffectCalcBase_C
local GE_EffectCalcBase = UnLua.Class()

---@override
---@param InParams FGameplayEffectCustomExecutionParameters
---@param OutParams FGameplayEffectCustomExecutionOutput
function GE_EffectCalcBase:Execute(InParams, OutParams)
    local CalcObjClass = UE.UClass.Load('/Game/Ikun/Blueprint/GAS/ExecCalc/BP_EffectCalcObj.BP_EffectCalcObj_C')
    local CalcObj = UE.NewObject(CalcObjClass, self) ---@type BP_EffectCalcObj_C
    CalcObj:InitEffectCalcData(InParams)
    local Ability = UE.UIkunFnLib.EffectContextGetAbility(CalcObj.Spec.EffectContext)

    self:OnExecute(CalcObj, Ability)
    
    OutParams = CalcObj.OutExecParams
end

---@protected
---@param CalcObj BP_EffectCalcObj_C
---@param Ability GA_IkunBase
function GE_EffectCalcBase:OnExecute(CalcObj, Ability)
end

return GE_EffectCalcBase