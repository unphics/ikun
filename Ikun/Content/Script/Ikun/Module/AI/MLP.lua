
---
---@brief 人工神经网络-多层感知机(MultilayerPerceptron)
---

---@enum InitWFuncType
local InitWFuncType = {
    Random = 1,
    Xavier = 2,
    He = 3,
    None = 4,
}

---@class InitWFunc 切换初始化的方法
---@desc 神经网络权重的初始化十分重要，它会影响你的神经网络最后能否训练成功。这里实现了3种典型的初始化方法
local InitWFunc = class.class 'InitWFunc' {
    InitWeights = function(InitWFunc, Neuron)end,
    XavierInitWeights = function(WeightsList)end,
    HeInitWeights = function(WeightsList)end,
    RandomInitWeights = function(WeightsList)end,
    NextGaussion = function()end,
}
---@param InitWFunc InitWFuncType
---@param Neuron Neuron
function InitWFunc:InitWeights(InitWFunc, Neuron)
    if InitWFunc == InitWFuncType.Xavier then
        self:XavierInitWeights(Neuron.Weights)
    elseif InitWFunc == InitWFuncType.He then
        self:HeInitWeights(Neuron.Weights)
    elseif InitWFunc == InitWFuncType.Random then
        self:RandomInitWeights(Neuron.Weights)
    else
    end
end
---@public 随机初始化(std = 0.01)：是比较普通的方法，深度学习新手接触的第一个初始化方式
---@param WeightsList number[]
function InitWFunc:RandomInitWeights(WeightsList)
    for i = 1, #WeightsList do
        -- 使用较小的标准差，适合普通的随机初始化
        WeightsList[i] = self:NextGaussion() * 0.01
    end
end
---@public Xavier初始化：适用于激活函数为 Sigmoid和Tanh 的场合
---@param WeightsList number[]
function InitWFunc:XavierInitWeights(WeightsList)
    local Scale = 1 / math.sqrt(#WeightsList)
    for i = 1, #WeightsList do
        WeightsList[i] = math.random() * 2 * Scale - Scale
    end
end
---@public He初始化：适用于激活函数为 ReLU及其衍生函数 如Leaky ReLU的场合
---@param WeightsList number[]
function InitWFunc:HeInitWeights(WeightsList)
    local StdDev = math.sqrt(2 / #WeightsList) -- 计算标准差
    for i = 1, #WeightsList do
        -- 生成服从正态分布的随机数，并乘以标准差
        WeightsList[i] = self:NextGaussion() * StdDev
    end
end
-- 用于生成服从标准正态分布的随机数的辅助方法
function InitWFunc:NextGaussion()
    local u1 = 1 - math.random()
    local u2 = 1 - math.random()
    -- 使用Box-Muller变换生成正态分布的随机数
    return math.sqrt(-2 * math.log(u1) * math.sin(2 * math.pi * u2))
end

---@enum ActivationFuncType 一般神经网络中所有隐藏层都使用同一种激活函数，输出层根据问题需求可能会使用和隐藏层不一样的激活函数。激活函数都有非线性且可导的特点，我也实现了一些典型的激活函数：
local ActivationFuncType = {
    Identify = 1, -- 直接输出(Identify)：不做处理直接输出，用于输出层
    Softmax = 2, --Softmax：把一系列输出转为总和为1的小数，并且维持彼此的大小关系，相当于把输出结果转为了概率。适用于多分类问题，但一定要搭配交叉熵损失函数使用。
    Tanh = 3, --Tanh：相当于Sigmoid的改造，将输出限制在了-1~1
    Sigmoid = 4, --Sigmoid：早期的主流，现在一般用于输出层需要将输出值限制在0~1的场合，或者是只有两个输出的二分问题
    ReLU = 5, --ReLU：当今的主流激活函数，长得十分友好，甚至不用加减运算。一般选它准没错
    LeakyReLU = 6, --Leaky ReLU：ReLU的改造，使得对负数输入也有响应，但并没有说它一定好于ReLU。如果你用ReLU训练出现问题，可以换这个试试
}
---@class ActivationFunc 激活函数
local ActivationFunc = class.class 'ActivationFunc' {
    ctor = function()end,
    Calc = function()end,
    CurAcFunc = nil,
}
---@param FuncType ActivationFuncType
function ActivationFunc:Calc(FuncType, Layer)
    if FuncType == ActivationFuncType.Softmax then
        self:Softmax_Calc(Layer)
    else
        if FuncType == ActivationFuncType.Sigmoid then
            self.CurAcFunc = self.Sigmoid_Calc
        elseif FuncType == ActivationFuncType.Tanh then
            self.CurAcFunc = self.Tanh_Calc
        elseif FuncType == ActivationFuncType.ReLU then
            self.CurAcFunc = self.ReLU_Calc
        elseif FuncType == ActivationFuncType.LeakyReLU then
            self.CurAcFunc = self.LeakyReLU_Calc
        else
            self.CurAcFunc = self.Indentify_Calc
        end
        for i = 0, i < Layer.Neurons.Length do
            Layer.Output[i] = self:CurAcFunc(Layer.Neurons[i].Sum)
        end
    end
end
---@param FuncType ActivationFuncType
function ActivationFunc:Diff(FuncType, Layer, Index)
    if FuncType == ActivationFuncType.Softmax then
        return self:Softmax_Diff(Layer, Index)
    elseif FuncType == ActivationFuncType.Tanh then
        return self:Sigmoid_Diff(Layer, Index)
    elseif FuncType == ActivationFuncType.Tanh then
        return self:Tanh_Diff(Layer, Index)
    elseif FuncType == ActivationFuncType.ReLU then
        return self:ReLU_Diff(Layer, Index)
    elseif FuncType == ActivationFuncType.LeakyReLU then
        return self:LeakyReLU_Diff(Layer, Index)
    else
        return self:Identify_Diff(Layer, Index)
    end
end
function ActivationFunc:Indentify_Calc(x)
    return x
end
function ActivationFunc:Identify_Diff()
    return 1
end
function ActivationFunc:Softmax_Calc(Layer)
    local Neurons = Layer.Neurons
    local ExpSum = 0
    for i = 0, i < Neurons.Length do
        Layer.Output[i] = math.exp(Neurons[i].Sum)
        ExpSum = ExpSum + Layer.Output
    end
    for i = 0, i < Neurons.Length do
        Layer.Output[i] = Layer.Output[i] / ExpSum
    end
end
function ActivationFunc:Softmax_Diff(OutLayer, Index)
    return OutLayer.OutLayer[Index] * (1 - OutLayer.OutLayer[Index])
end
function ActivationFunc:Sigmoid_Calc(x)
    return 1 / (1 + math.exp(-x))
end
function ActivationFunc:Sigmoid_Diff(OutLayer, Index)
    return OutLayer.Output[Index] * (1 - OutLayer.Output[Index])
end
function ActivationFunc:Tanh_Calc(x)
    local ExpVal = math.exp(-x)
    return (1 - ExpVal) / 1 + ExpVal
end
function ActivationFunc:Tanh_Diff(OutLayer, Index)
    return 1 - math.pow(OutLayer.Output[Index], 2)
end
function ActivationFunc:ReLU_Calc(x)
    return x > 0 and x or 0
end
function ActivationFunc:ReLU_Diff(OutLayer, Index)
    return OutLayer.Neurons[Index].Sum > 0 and 1 or 0
end
function ActivationFunc:LeakyReLU_Calc(x)
    return x > 0 and x or 0.01 * x
end
function ActivationFunc:LeakyReLU_Diff(OutLayer, Index)
    return OutLayer.Neurons[Index].Sum > 0 and 1 or 0.01
end