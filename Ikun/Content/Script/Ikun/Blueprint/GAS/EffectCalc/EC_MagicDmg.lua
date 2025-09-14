
---
---@brief 魔法伤害计算
---@author zys
---@data Sun Jun 08 2025 12:55:19 GMT+0800 (中国标准时间)
---

local EffectConfig = require('Ikun/Blueprint/GAS/Config/EffectConfig')

---@class EC_MagicDmg : GE_EffectCalcBase
local EC_MagicDmg = UnLua.Class('Ikun/Blueprint/GAS/EffectCalc/GE_EffectCalcBase')

---@override
function EC_MagicDmg:OnExecute(CalcObj, Ability, Effect, OptionObj)
    local MgcDmgCfgCorr = 0
    if Effect and Effect.EffectCfgId then
        local Info = EffectConfig[Effect.EffectCfgId] ---@type EffectConfig
        if Info then
            MgcDmgCfgCorr = Info.EffectCorr
        end
    end
    local SrcMagicPowerVal = CalcObj:ReadAttrValue('MagicPower', true)
    local TarMgcDefVal = CalcObj:ReadAttrValue('MagicalDefense', false)
    local PercMgcDefVal = TarMgcDefVal / (TarMgcDefVal + 100) -- log的底数为nil的话默认是e
    local MgcDmgVal = SrcMagicPowerVal * MgcDmgCfgCorr * (1 - PercMgcDefVal)
    -- log.dev('EC_MagicDmg:OnExecute ', SrcMagicPowerVal, MgcDmgCfgCorr, PercMgcDefVal, MgcDmgVal)
    local TarHealthVal = CalcObj:ReadAttrValue('Health', false)
    -- log.dev('EC_MagicDmg:OnExecute TarHealthVal', TarHealthVal)
    CalcObj:ModiAttrValue('Health', -MgcDmgVal, UE.EGameplayModOp.Additive)
end

return EC_MagicDmg