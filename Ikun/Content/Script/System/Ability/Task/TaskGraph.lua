
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

---@class TaskGraphClass
local TaskGraphClass = Class3.Class("TaskGraph")

function TaskGraphClass:Ctor(InOwner)
    self._Owner = InOwner
    self._bRunning = false
    self.DelayTasks = {}
    self.FollowTasks = {}
    self.WaitTasks = {}
    self.RunningTasks = {}
end

function TaskGraphClass:BeginTaskGraph()
    -- 开始任务图，初始化运行状态
    self._bRunning = true
end

function TaskGraphClass:EndTaskGraph()
    -- 结束任务图，清理所有任务
    self._bRunning = false
    self.DelayTasks = {}
    self.FollowTasks = {}
    self.WaitTasks = {}
    self.RunningTasks = {}
end

function TaskGraphClass:TickTaskGraph(DeltaTime)
    if not self._bRunning then
        return
    end
    
    -- 处理延迟任务
    local completedTasks = {}
    for i, taskData in ipairs(self.DelayTasks) do
        taskData.DelayTime = taskData.DelayTime - DeltaTime
        if taskData.DelayTime <= 0 then
            -- 延迟时间到，执行任务
            table.insert(self.RunningTasks, taskData.Task)
            table.insert(completedTasks, i)
        end
    end
    
    -- 移除已完成的延迟任务
    for i = #completedTasks, 1, -1 do
        table.remove(self.DelayTasks, completedTasks[i])
    end
end

---@public
function TaskGraphClass:AddDelayTask(InDelayTime, InDelayTask)
    table.insert(self.DelayTasks, {Task = InDelayTask, DelayTime = InDelayTime})
end

---@public
function TaskGraphClass:AddFollowTask(InPreTask, InNextTask)
    local tasks = self.FollowTasks[InPreTask]
    if not tasks then
        tasks = {}
        self.FollowTasks[InPreTask] = tasks
    end
    table.insert(tasks, InNextTask)
end

---@public
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
    -- 从运行任务列表中移除
    for i, task in ipairs(self.RunningTasks) do
        if task == InTask then
            table.remove(self.RunningTasks, i)
            break
        end
    end
    
    -- 处理跟随任务
    local followTasks = self.FollowTasks[InTask]
    if followTasks then
        for _, task in ipairs(followTasks) do
            table.insert(self.RunningTasks, task)
        end
        self.FollowTasks[InTask] = nil
    end
end

---@public
function TaskGraphClass:TriggerEvent(InEvent)
    -- 处理等待事件的任务
    local waitTasks = self.WaitTasks[InEvent]
    if waitTasks then
        for _, task in ipairs(waitTasks) do
            table.insert(self.RunningTasks, task)
        end
        self.WaitTasks[InEvent] = nil
    end
end

return TaskGraphClass