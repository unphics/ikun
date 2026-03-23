
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-属性修改器
--  File        : AttrModifier.lua
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
local AttrDef = require("System/Ability/Attr/AttrDef")
local fficlass = require("Core/FFI/fficlass")



---@class AttrModifierClass
---@field public ModId integer 修改器的唯一Id
---@field public ModAttrId integer 修改的属性类型
---@field public ModValue integer 修改的值
---@field public ModPriority integer 优先级
local AttrModifierClass = fficlass.define('AttrModifierClass', [[
    typedef struct {
        uint32_t ModId;
        int32_t ModValue;
        uint8_t ModAttrId;
        uint8_t ModPriority;
    } AttrModifierClass;
]])

---@public
---@return string
function AttrModifierClass:__tostring()
    return string.format("AttrModifier(Id=%i,Attr=%s,Value=%i,Priority=%i)", self.ModId, AttrDef.ToKey(self.ModAttrId), self.ModValue, self.ModPriority)
end

AttrModifierClass = AttrModifierClass:RegisterClass()

return AttrModifierClass