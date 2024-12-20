
---
---@brief 多层感知机 MultilayerPerceptron
---

---@enum InitFuncType
local InitFuncType = {
    Random = 1,
    Xavier = 2,
    He = 3,
    None = 4,
}

---@class InitFunc 切换初始化的方法
local InitFunc = class.class 'InitFunc' {
    InitWeights = function(InitWFunc, Neuron)end,
    XavierInitWeights = function(WeightsList)end,
    HeInitWeights = function(WeightsList)end,
    RandomInitWeights = function(WeightsList)end,
    NextGaussion = function()end,
}
---@param InitWFunc InitFuncType
---@param Neuron Neuron
function InitFunc:InitWeights(InitWFunc, Neuron)
    if InitWFunc == InitFuncType.Xavier then
        self:XavierInitWeights(Neuron.Weights)
    elseif InitWFunc == InitFuncType.He then
        self:HeInitWeights(Neuron.Weights)
    elseif InitWFunc == InitFuncType.Random then
        self:RandomInitWeights(Neuron.Weights)
    else
    end
end
---@param WeightsList number[]
function InitFunc:RandomInitWeights(WeightsList)
    for i = 1, #WeightsList do
        -- 使用较小的标准差，适合普通的随机初始化
        WeightsList[i] = self:NextGaussion() * 0.01
    end
end
---@param WeightsList number[]
function InitFunc:XavierInitWeights(WeightsList)
    local Scale = 1 / math.sqrt(#WeightsList)
    for i = 1, #WeightsList do
        WeightsList[i] = math.random() * 2 * Scale - Scale
    end
end
---@param WeightsList number[]
function InitFunc:HeInitWeights(WeightsList)
    local StdDev = math.sqrt(2 / #WeightsList) -- 计算标准差
    for i = 1, #WeightsList do
        -- 生成服从正态分布的随机数，并乘以标准差
        WeightsList[i] = self:NextGaussion() * StdDev
    end
end
-- 用于生成服从标准正态分布的随机数的辅助方法
function InitFunc:NextGaussion()
    local u1 = 1 - math.random()
    local u2 = 1 - math.random()
    -- 使用Box-Muller变换生成正态分布的随机数
    return math.sqrt(-2 * math.log(u1) * math.sin(2 * math.pi * u2))
end
--[[
local math_sqrt = math.sqrt
local math_log = math.log
local math_sin = math.sin
local math_pi = math.pi
local function NextGaussian()
    local u1 = 1.0 - math.random()
    local u2 = 1.0 - math.random()
    return math_sqrt(-2.0 * math_log(u1)) * math_sin(2.0 * math_pi * u2)
end
]]