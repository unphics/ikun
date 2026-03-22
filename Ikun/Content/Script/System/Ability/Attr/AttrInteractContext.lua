
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-属性-属性交互上下文
--  File        : AttrInteractContext.lua
--  Author      : zhengyanshuai
--  Date        : Mon Mar 16 2026 16:31:18 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')

---@class AttrInteractContextClass
---@field public InteractCarrier any 载体
---@field public InteractAttr integer
---@field public Imposer AbilityPartClass
---@field public Receiver AbilityPartClass
---@field public ImposeFunc AttrImposeFormulaFunction
---@field public ReceiveFunc AttrReceiveFormulaFunction
---@field public ImposeValue number
---@field public ReceiveValue number
local AttrInteractContextClass = Class3.Class('AttrInteractContextClass')

function AttrInteractContextClass:Ctor(InCarrier)
    self.InteractCarrier = InCarrier
end

---@public
---@param InImposer AbilityPartClass
---@param InImposeFunc AttrImposeFormulaFunction
---@param InInteractAttr integer
function AttrInteractContextClass:SetImposeInfo(InImposer, InImposeFunc, InInteractAttr)
    self.Imposer = InImposer
    self.ImposeFunc = InImposeFunc
    self.InteractAttr = InInteractAttr
end

---@public
---@param InReceiver AbilityPartClass
---@param InReceiveFunc AttrReceiveFormulaFunction
function AttrInteractContextClass:SetReceiveInfo(InReceiver, InReceiveFunc)
    self.Receiver = InReceiver
    self.ReceiveFunc = InReceiveFunc
end

---@public
---@return number
function AttrInteractContextClass:CalcAttrImposeValue()
    self.ImposeValue = self.ImposeFunc(self.Imposer:GetAttrSet():GetFormulaProxy(),
        self.Receiver:GetAttrSet():GetFormulaProxy())
    return self.ImposeValue
end

---@public
---@return number
function AttrInteractContextClass:CalcAttrReceviveValue()
    self.ReceiveValue = self.ReceiveFunc(self.Imposer:GetAttrSet():GetFormulaProxy(),
        self.Receiver:GetAttrSet():GetFormulaProxy(), self.ImposeValue)
    return self.ReceiveValue
end

return AttrInteractContextClass