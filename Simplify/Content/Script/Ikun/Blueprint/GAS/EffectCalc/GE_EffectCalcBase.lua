
---
---@brief 伤害计算核心逻辑
---@author zys
---@data Mon Jun 02 2025 01:42:51 GMT+0800 (中国标准时间)
---

---@class GE_EffectCalcBase: GE_EffectCalcBase_C
local GE_EffectCalcBase = UnLua.Class()

-- function GE_EffectCalcBase:OnCalcEffectData()
--     local ContextHandle = self.Spec.EffectContext
--     local Ability = UE.UIkunFnLib.EffectContextGetAbility(self.Spec.EffectContext)

--     local PhyDmgCfgCorr = 1

--     local SourceAttackPowerVal = self:ReadAttrValue('AttackPower', true)
    
--     local TargetPhysicalDefenseVal = self:ReadAttrValue('PhysicalDefense', false)
--     local PercentPhysicalDefenseVal = math.log(TargetPhysicalDefenseVal) -- log的底数为nil的话默认是e
--     local PhyDmgVal = SourceAttackPowerVal * PhyDmgCfgCorr * (1 - PercentPhysicalDefenseVal)

--     log.dev('GE_EffectCalcBase:OnCalcEffectData qqqq', SourceAttackPowerVal, PhyDmgCfgCorr, PercentPhysicalDefenseVal, PhyDmgVal)
    
    
--     local TargetHealthVal = self:ReadAttrValue('Health', false)
    
--     log.dev('GE_EffectCalcBase:OnCalcEffectData', TargetHealthVal)

--     self:ModiAttrValue('Health', -3, UE.EGameplayModOp.Additive)
-- end

---@param InParams FGameplayEffectCustomExecutionParameters
---@param OutParams FGameplayEffectCustomExecutionOutput
function GE_EffectCalcBase:Execute(InParams, OutParams)
    local CalcObjClass = UE.UClass.Load('/Game/Ikun/Blueprint/GAS/ExecCalc/BP_EffectCalcObj.BP_EffectCalcObj_C')
    local CalcObj = UE.NewObject(CalcObjClass, self) ---@type BP_EffectCalcObj_C
    CalcObj:InitEffectCalcData(InParams)
    local Ability = UE.UIkunFnLib.EffectContextGetAbility(CalcObj.Spec.EffectContext)
    local PhyDmgCfgCorr = 1
    local SrcAttackPowerVal = CalcObj:ReadAttrValue('AttackPower', true)
    local TarPhyDefVal = CalcObj:ReadAttrValue('PhysicalDefense', false)
    local PercPhyDefVal = math.log(TarPhyDefVal) -- log的底数为nil的话默认是e
    local PhyDmgVal = SrcAttackPowerVal * PhyDmgCfgCorr * (1 - PercPhyDefVal)
    log.dev(' GE_EffectCalcBase:Execute ', SrcAttackPowerVal, PhyDmgCfgCorr, PercPhyDefVal, PhyDmgVal)
    local TarHealthVal = CalcObj:ReadAttrValue('Health', false)
    log.dev('GE_EffectCalcBase:Execute', TarHealthVal)
    CalcObj:ModiAttrValue('Health', -3, UE.EGameplayModOp.Additive)
    OutParams = CalcObj.OutExecParams
end

return GE_EffectCalcBase