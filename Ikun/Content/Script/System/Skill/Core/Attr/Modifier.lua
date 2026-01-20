
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 技能系统-属性修改器
--  File        : Modifier.lua
--  Author      : zhengyanshuai
--  Date        : Sun Jan 18 2026 13:41:39 GMT+0800 (中国标准时间)
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