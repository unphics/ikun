
---
---@brief 伤害计算核心逻辑
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
    local PhyDmgCfgCorr = 1
    local SrcAttackPowerVal = CalcObj:ReadAttrValue('AttackPower', true)
    local TarPhyDefVal = CalcObj:ReadAttrValue('PhysicalDefense', false)
    local PercPhyDefVal = math.log(TarPhyDefVal) -- log的底数为nil的话默认是e
    local PhyDmgVal = SrcAttackPowerVal * PhyDmgCfgCorr * (1 - PercPhyDefVal)
    log.dev('GE_EffectCalcBase:Execute ', SrcAttackPowerVal, PhyDmgCfgCorr, PercPhyDefVal, PhyDmgVal)
    local TarHealthVal = CalcObj:ReadAttrValue('Health', false)
    log.dev('GE_EffectCalcBase:Execute', TarHealthVal)
    CalcObj:ModiAttrValue('Health', -3, UE.EGameplayModOp.Additive)
end

return GE_EffectCalcBase