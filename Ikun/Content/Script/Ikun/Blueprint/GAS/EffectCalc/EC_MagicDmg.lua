
---
---@brief   魔法伤害
---@author  zys
---@data    Sun Jun 08 2025 12:55:19 GMT+0800 (中国标准时间)
---

---@class EC_MagicDmg : GE_EffectCalcBase
local EC_MagicDmg = UnLua.Class('Ikun/Blueprint/GAS/EffectCalc/GE_EffectCalcBase')

---@override
function EC_MagicDmg:OnExecute(CalcObj, Ability, Effect, OptionObj)
    local context = OptionObj.EffectContext ---@as EffectContext

    local magicDmgCorr = context.EffectConfig.EffectCorr
    local srcMagicPowerVal = CalcObj:ReadAttrValue('MagicPower', true) -- 法强
    local tarMgcDefVal = CalcObj:ReadAttrValue('MagicalDefense', false) -- 魔抗
    local percMgcDefVal = tarMgcDefVal / (tarMgcDefVal + 100) -- log的底数为nil的话默认是e
    local magicDmgVal = srcMagicPowerVal * magicDmgCorr * (1 - percMgcDefVal) -- 最终修改量

    -- do -- log
    --     log.debug('EC_MagicDmg:OnExecute ', srcMagicPowerVal, magicDmgCorr, percMgcDefVal, magicDmgVal)
    --     local TarHealthVal = CalcObj:ReadAttrValue('Health', false)
    --     log.debug('EC_MagicDmg:OnExecute TarHealthVal', TarHealthVal)
    -- end
    
    CalcObj:ModiAttrValue('Health', -magicDmgVal, UE.EGameplayModOp.Additive) -- 修改目标血量
end

return EC_MagicDmg