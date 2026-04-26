
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-能力-能力容器
--  File        : AbilityContainer.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:31:32 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]
local Class3 = require("Core/Class/Class3")
local ConfigSystem = require("System/Config/ConfigSystem")
local FileSystem = require("System/File/FileSystem")
local log = require('Core/Log/log')
local AbilityFactoryClass = require("System/Ability/Ability/AbilityFactory")
local TagUtils = require("System/Ability/Tag/TagUtils")

---@class AbilityContainerClass
---@field private __Abilities AbilityClass[] 能力数组
---@field private __OwnerPart AbilityPartClass
local AbilityContainerClass = Class3.Class("AbilityContainerClass")

function AbilityContainerClass:Ctor(InOwnerPart)
    self.__Abilities = {}
    self.__OwnerPart = InOwnerPart
end

---@public
function AbilityContainerClass:TickAbilityContainer(InDeltaTime, InTimestampSec)
    for i = 1, #self.__Abilities do
        local ability = self.__Abilities[i]
        ability:TickAbility(InDeltaTime, InTimestampSec)
    end
end

---@public
---@param InAbility AbilityClass
function AbilityContainerClass:AddAbility(InAbility)
    table.insert(self.__Abilities, InAbility)
end

---@public
---@param InAbility AbilityClass
function AbilityContainerClass:RemoveAbility(InAbility)
    for i = 1, #self.__Abilities do
        if self.__Abilities[i] == InAbility then
            table.remove(self.__Abilities, i)
            break
        end
    end
end

---@public
---@param InTag integer
function AbilityContainerClass:FindAbilitiesByTag(InTag)
    local abilities = {}
    ---@todo zys
    for i = 1, #self.__Abilities do
    end
    return abilities
end

---@public
---@param InAbilitiesKey string
function AbilityContainerClass:FindAbilitiesByKey(InAbilitiesKey)
    local abilities = {}
    for i = 1, #self.__Abilities do
        local ability = self.__Abilities[i]
        if ability:GetAbilityConfig().AbilityKey == InAbilitiesKey then
            table.insert(abilities, ability)
        end
    end
    return abilities
end

return AbilityContainerClass