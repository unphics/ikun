
---
---@brief   物理伤害
---@author  zys
---@data    Sun Jun 08 2025 12:55:19 GMT+0800 (中国标准时间)
---

---@class EC_PhyDmg : GE_EffectCalcBase
local EC_PhyDmg = UnLua.Class('Ikun/Blueprint/GAS/EffectCalc/GE_EffectCalcBase')

---@override
function EC_PhyDmg:OnExecute(CalcObj, Ability, Effect, OptionObj)
    local PhyDmgCfgCorr = 1
    local SrcAttackPowerVal = CalcObj:ReadAttrValue('AttackPower', true)
    local TarPhyDefVal = CalcObj:ReadAttrValue('PhysicalDefense', false)
    local PercPhyDefVal = math.log(TarPhyDefVal) -- log的底数为nil的话默认是e
    local PhyDmgVal = SrcAttackPowerVal * PhyDmgCfgCorr * (1 - PercPhyDefVal)
    log.debug('EC_PhyDmg:OnExecute ', SrcAttackPowerVal, PhyDmgCfgCorr, PercPhyDefVal, PhyDmgVal)
    local TarHealthVal = CalcObj:ReadAttrValue('Health', false)
    log.debug('EC_PhyDmg:OnExecute', TarHealthVal)
    CalcObj:ModiAttrValue('Health', -3, UE.EGameplayModOp.Additive)
end

return EC_PhyDmg