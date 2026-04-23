
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-属性管理器
--  File        : AttrManager.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 16 2026 23:09:10 GMT+0800 (中国标准时间)
--  Description : 管理属性配置, 提供属性集工厂
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local FileSystem = require("System/File/FileSystem")
local ConfigSystem = require("System/Config/ConfigSystem")
local ExpLib = require("System/Ability/Exp/ExpLib")
local AttrSetClass = require("System/Ability/Attr/AttrSet")
local AttrDef = require("System/Ability/Attr/AttrDef")
local AttrModifierClass = require("System/Ability/Attr/AttrModifier")
local log = require("Core/Log/log")
local AttrConfigClass = require("System/Ability/Attr/AttrConfig")
local AttrModifierFactoryClass = require("System/Ability/Attr/AttrModifierFactory")

---@class AttrManager
---@field protected _System AbilitySystem
---@field protected _AttrModGenId integer
local AttrManager = Class3.Class("AttrManager")

---@private
---@param InSystem AbilitySystem
function AttrManager:Ctor(InSystem)
    self._System = InSystem
    self._AttrModGenId = 0
end

---@public [Init]
function AttrManager:InitAttrManager()
    AttrConfigClass.Get()
    AttrModifierFactoryClass.Get()
end

return AttrManager