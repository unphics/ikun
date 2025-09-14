
---
---@brief 生命值回复计算
---@author zys
---@data Sun Jun 08 2025 22:25:56 GMT+0800 (中国标准时间)
---

local EffectConfig = require('Ikun/Blueprint/GAS/Config/EffectConfig')

---@class EC_Heal : GE_EffectCalcBase
local EC_Heal = UnLua.Class('Ikun/Blueprint/GAS/EffectCalc/GE_EffectCalcBase')

function EC_Heal:OnExecute(CalcObj, Ability, Effect, OptionObj)
    local HealCfgVal = 0
    if Effect and EffectConfig[Effect.EffectCfgId] then
        local Cfg = EffectConfig[Effect.EffectCfgId] ---@type EffectConfig
        HealCfgVal = Cfg.EffectVal
    end
    CalcObj:ModiAttrValue('Health', HealCfgVal, UE.EGameplayModOp.Additive)
end

return EC_Heal