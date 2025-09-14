
local EffectConfig = {}

---@class EffectConfig
---@field EffectId number
---@field EffectDesc string
---@field EffectCorr number
---@field EffectVal number
EffectConfig[1] = {
    EffectId = 1,
    EffectDesc = '火球爆炸',
    EffectCorr = 0.4,
}

EffectConfig[2] = {
    EffectId = 2,
    EffectDesc = '治疗',
    EffectVal = 5,
}

return EffectConfig