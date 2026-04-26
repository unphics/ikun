
--[[
-- -----------------------------------------------------------------------------
--  Brief       : TaskManagerClass
--  File        : TaskManager.lua
--  Author      : zhengyanshuai
--  Date        : Sun Apr 26 2026 18:26:24 GMT+0800 (中国标准时间)
--  Description : 任务管理器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local log = require("Core/Log/log")
local TaskConfigClass = require("System/Ability/Task/TaskConfig")

---@class TaskManager
local TaskManager = Class3.Class("TaskManager")

function TaskManager:Ctor()
end

function TaskManager:InitTaskManager()
    TaskConfigClass.Get()
end

function TaskManager:TickTaskManager()
end

return TaskManager