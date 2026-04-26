
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-属性-属性工厂
--  File        : AttrFactory.lua
--  Author      : zhengyanshuai
--  Date        : Tue Apr 21 2026 17:31:11 GMT+0800 (中国标准时间)
--  Description : 属性工厂
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local ConfigSystem = require("System/Config/ConfigSystem")
local FileSystem = require("System/File/FileSystem")
local log = require('Core/Log/log')
local ExpLib = require("System/Ability/Exp/ExpLib")
local TagUtils = require("System/Ability/Tag/TagUtils")
local AttrDef = require("System/Ability/Attr/AttrDef")
local AttrSetClass = require("System/Ability/Attr/AttrSet")
local AttrConfigClass = require("System/Ability/Attr/AttrConfig")

---@class AttrFactoryClass
---@field private __CachedClasses table<string, AttrSetClass>
local AttrFactoryClass = Class3.Class("AttrConfigClass")

AttrFactoryClass.ATTRSET_SCRIPT_PATH = "Module/Ability/Attr/"

local factory = nil

---@public
---@return AttrFactoryClass
function AttrFactoryClass.Get()
    if not factory then
        factory = AttrFactoryClass:New()
    end
    return factory
end

function AttrFactoryClass:Ctor()
    self.__CachedClasses = {}
end

---@public
---@param InAbilityPart AbilityPartClass
---@return AttrSetClass
function AttrFactoryClass:CreateAttrSet(InAttrSetClassName, InAbilityPart)
    local setClass = self:__GetOrLoadAttrSetClass(InAttrSetClassName)
    if not setClass then
        setClass = AttrSetClass
    end
    local attributes = AttrDef.NewAttrIdArr(0)
    local set = setClass:New(attributes, InAbilityPart)
    return set
end

---@private
---@return AttrSetClass?
function AttrFactoryClass:__GetOrLoadAttrSetClass(InClassName)
    local fullPath = nil
    if InClassName then
        local setClass = self.__CachedClasses[InClassName]
        if setClass then
            return setClass
        end
        fullPath = AttrFactoryClass.ATTRSET_SCRIPT_PATH..InClassName
        local success, setClass = pcall(require, fullPath)
        if success and setClass then
            self.__CachedClasses[InClassName] = setClass
            return setClass
        end
    end
    log.error_fmt("AttrFactoryClass:__GetOrLoadAttrSetClass(): Failed to load class! path=[%s]", fullPath)
end

return AttrFactoryClass