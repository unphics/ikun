
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-属性修改器
--  File        : Modifier.lua
--  Author      : zhengyanshuai
--  Date        : Tue Jan 20 2026 22:56:40 GMT+0800 (中国标准时间)
--  Description : 修改属性
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')

---@class ModifierClass
---@field AttrKey number
---@field ModOp string
---@field ModValue number
---@field ModSource table
local ModifierClass = Class3.Class('AttrSetClass')

---@public
function ModifierClass:Ctor(InAttrKey, InModOp, InModValue, InModSource)
    self.AttrKey = InAttrKey
    self.ModOp = InModOp
    self.ModValue = InModValue
    self.ModSource = InModSource
end

return ModifierClass