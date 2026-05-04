
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-增益-增益管理器
--  File        : BuffManager.lua
--  Author      : zhengyanshuai
--  Date        : Tue Feb 10 2026 14:19:55 GMT+0800 (中国标准时间)
--  Description : 负责增益的生命周期管理, 统一调度, "规则执行", 归档与查询
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local TagUtils = require("System/Ability/Tag/TagUtils")
local FileSystem = require("System/File/FileSystem")
local ConfigSystem = require("System/Config/ConfigSystem")
local BuffContainer = require("System/Ability/Buff/BuffContainer")
local StrUtils = require("Core/Utils/StrUtils")
local log = require("Core/Log/log")
local BuffBaseClass = require("System/Ability/Buff/BuffBase")
local BuffConfigClass = require("System/Ability/Buff/BuffConfig")
local TimeLib = require("Core/TimeLib")

---@class BuffManager
---@deprecated
---@field protected _System AbilitySystem
---@field protected _BuffConfigs table<string, BuffConfig> -- Key -> Config
---@field protected _BuffContainers BuffContainerClass[]
local BuffManager = Class3.Class("BuffManager")

---@public
---@param InSystem AbilitySystem
function BuffManager:Ctor(InSystem)
    self._System = InSystem
    self._BuffContainers = {}
end

---@public
function BuffManager:InitBuffManager()
    BuffConfigClass.Get()
end

---@public
---@param InDeltaTime number
function BuffManager:TickBuffManager(InDeltaTime)
    local now = TimeLib.GetTimestampSec()
    self:_TickBuffManager(InDeltaTime, now)
end

---@public [BuffContainer]
---@param InOwnerPart AbilityPartClass
---@return BuffContainerClass
function BuffManager:AcquireBuffContainer(InOwnerPart)
    local container= BuffContainer:New(self, InOwnerPart)
    table.insert(self._BuffContainers, container)
    return container
end

---@public [BuffContainer]
---@param InBuffContainer BuffContainerClass
function BuffManager:ReleaseBuffContainer(InBuffContainer)
    for i = 1, #self._BuffContainers do
        local container = self._BuffContainers[i]
        if container == InBuffContainer then
            table.remove(self._BuffContainers, i)
            break
        end
    end
end

---@public [BuffContainer]
---@param InDeltaTime number
---@param InTimestampSec number
function BuffManager:_TickBuffManager(InDeltaTime, InTimestampSec)
    for i = 1, #self._BuffContainers do
        local container = self._BuffContainers[i]
        container:TickBuffContainer(InDeltaTime, InTimestampSec)
    end
end

---@public
---@param InBuffKey string
---@return BuffBaseClass?
function BuffManager:CreateBuff(InBuffKey)
    local config = self:LookupBuffConfig(InBuffKey)
    if not config then
        log.error_fmt("BuffManager:CreateBuff(): Invalid BuffKey = [%s]", InBuffKey)
        return
    end
    local buffClass = self:_LoadBuffClass(config.BuffTemplate)
    local buff = buffClass:New(config)
    return buff
end

return BuffManager