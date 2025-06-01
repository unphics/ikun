--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class BP_EffectCalc: BP_EffectCalc_C
local BP_EffectCalc = UnLua.Class()

function BP_EffectCalc:OnCalcEffectData()
    local value = self:ReadAttrValue('Health', false)
    log.dev('BP_EffectCalc:OnCalcEffectData', value)
    self:ModiAttrValue('Health', -3, UE.EGameplayModOp.Additive)
end

return BP_EffectCalc