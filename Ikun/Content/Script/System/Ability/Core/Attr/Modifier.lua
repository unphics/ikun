
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-属性修改器
--  File        : Modifier.lua
--  Author      : zhengyanshuai
--  Date        : Tue Jan 20 2026 22:56:40 GMT+0800 (中国标准时间)
--  Description : 修改属性
--  Todo        : 考虑添加优先级成员变量
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')

---@class ModifierClass
---@field public ModId number 修改器的唯一Id
---@field public AttrKey number 修改的属性类型
---@field public ModOp ModOpDef 修改操作符, 加/乘/覆盖
---@field public ModValue number 修改值
---@field public ModSource any 修改源, 可以是Buff实例或者武器实例或者角色等信息的混合
local ModifierClass = Class3.Class('AttrSetClass')

---@public
function ModifierClass:Ctor(InAttrKey, InModOp, InModValue, InModSource)
    self.AttrKey = InAttrKey
    self.ModOp = InModOp
    self.ModValue = InModValue
    self.ModSource = InModSource
end

return ModifierClass