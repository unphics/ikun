
--[[
-- -----------------------------------------------------------------------------
--  Brief       : TaskGraphClass
--  File        : TaskGraph.lua
--  Author      : zhengyanshuai
--  Date        : Sun Apr 12 2026 21:09:36 GMT+0800 (中国标准时间)
--  Description : 任务图
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local log = require("Core/Log/log")
local Delegate = require("Core/Delegate")

---@class TaskGraphClass
local TaskGraphClass = Class3.Class("TaskGraph")

function TaskGraphClass:Ctor(InOwner)
    self._Owner = InOwner
    self.DelayTasks = {}
    self.FollowTasks = {}
    self.WaitTasks = {}
    self.RunningTasks = {}
end

function TaskGraphClass:BeginTaskGraph()
end

function TaskGraphClass:EndTaskGraph()
end

function TaskGraphClass:TickTaskGraph(DeltaTime)
end

---@public
function TaskGraphClass:AddDelayTask(InDelayTime, InDelayTask)
    table.insert(self.DelayTasks, {Task = InDelayTask, DelayTime = InDelayTime})
end

function TaskGraphClass:AddFollowTask(InPreTask, InNextTask)
    local tasks = self.FollowTasks[InPreTask]
    if not tasks then
        tasks = {}
        self.FollowTasks[InPreTask] = tasks
    end
    table.insert(tasks, InNextTask)
end

function TaskGraphClass:AddWaitEventTask(InEvent, InWaitTask)
    local tasks = self.WaitTasks[InEvent]
    if not tasks then
        tasks = {}
        self.WaitTasks[InEvent] = tasks
    end
    table.insert(tasks, InWaitTask)
end

---@public
---@return boolean
function TaskGraphClass:IsAnyTaskRunning() -- const
    return #self.RunningTasks > 0
end

---@public
function TaskGraphClass:NotifyTaskEnd(InTask)
end

return TaskGraphClass