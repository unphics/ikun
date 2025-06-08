--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class EC_PhyDmg : GE_EffectCalcBase
local EC_PhyDmg = UnLua.Class('Ikun/Blueprint/GAS/EffectCalc/GE_EffectCalcBase')

---@override
function EC_PhyDmg:OnExecute(CalcObj, Ability)
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

return EC_PhyDmg