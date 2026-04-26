
--[[
-- -----------------------------------------------------------------------------
--  Brief       : TaskConfigClass
--  File        : TaskConfig.lua
--  Author      : zhengyanshuai
--  Date        : Sun Apr 26 2026 18:17:59 GMT+0800 (中国标准时间)
--  Description : 任务实配置
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local log = require("Core/Log/log")
local Delegate = require("Core/Delegate")
local FileSystem = require("System/File/FileSystem")
local ConfigSystem = require("System/Config/ConfigSystem")

local TASK_CONFIG_PATH = "Ability/Ability/Task.csv"

---@class TaskConfigClass
local TaskConfigClass = Class3.Class("TaskConfigClass")

local config = nil

---@return TaskConfigClass
function TaskConfigClass.Get()
    if not config then
        config = TaskConfigClass:New()
        config:LoadTaskConfigs()
    end
    return config
end

function TaskConfigClass:Ctor()
end

---@public
function TaskConfigClass:LoadTaskConfigs()
    local file = FileSystem.Get():MustReadSConfigFile(TASK_CONFIG_PATH)
    log.assert_fmt(file, "TaskConfigClass:LoadTaskConfigs(): Failed to read [%s]", TASK_CONFIG_PATH)

    local parser = ConfigSystem.Get():CreateCSVParser(file)
    local data = parser:ToRows():ExtractHeaders():ToGrid():ToMap():GetResult()
    local a = 1
end

return TaskConfigClass