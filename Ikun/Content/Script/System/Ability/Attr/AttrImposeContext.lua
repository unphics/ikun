
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-属性-属性施加上下文
--  File        : AttrImposeContext.lua
--  Author      : zhengyanshuai
--  Date        : Mon Mar 16 2026 16:31:18 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')

---@class AttrImposeContextClass
---@field public ImposeSource AbilityPartClass
---@field public ImposeTarget AbilityPartClass
---@field public ImposeCarrier any
---@field public ImposeAttr integer
---@field public ImposeFunc AttrImposeFormulaFunction
---@field public ImposeValue number
local AttrImposeContextClass = Class3.Class('AttrImposeContextClass')

function AttrImposeContextClass:Ctor()
end

---@public
---@return number
function AttrImposeContextClass:CalcAttrImposeValue()
    self.ImposeValue = self.ImposeFunc(self.ImposeSource:GetAttrSet():GetFormulaProxy(), self.ImposeTarget:GetAttrSet():GetFormulaProxy())
    return self.ImposeValue
end

return AttrImposeContextClass