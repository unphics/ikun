
--[[
-- -----------------------------------------------------------------------------
--  Brief       : TaskBaseClass
--  File        : TaskBase.lua
--  Author      : zhengyanshuai
--  Date        : Sun Apr 12 2026 12:39:03 GMT+0800 (中国标准时间)
--  Description : 任务实例
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local log = require("Core/Log/log")
local Delegate = require("Core/Delegate")

---@class TaskBaseClass
---@field private __Owner any
---@field private __TaskGraph TaskGraphClass?
---@field private __bRunning boolean
local TaskBaseClass = Class3.Class("TaskBaseClass")

function TaskBaseClass:Ctor(InOwner)
    self.__Owner = InOwner
    self.__bRunning = false
end

---@public
function TaskBaseClass:BeginTask()
    self.__bRunning = true
end

---@public
function TaskBaseClass:EndTask()
    if not self.__bRunning then
        return
    end
    
    self.__bRunning = false
    local graph = self:GetTaskGraph()
    if graph then
        graph:NotifyTaskEnd(self)
    end
end

---@public
function TaskBaseClass:TickTask(DeltaTime)
    if not self.__bRunning then
        return
    end
end

---@public
---@return boolean
function TaskBaseClass:IsTaskRunning() -- const
    return self.__bRunning
end

---@public
---@param InTaskGraph TaskGraphClass?
function TaskBaseClass:SetTaskGraph(InTaskGraph)
    self.__TaskGraph = InTaskGraph
end

---@public
---@return TaskGraphClass?
function TaskBaseClass:GetTaskGraph() -- const
    return self.__TaskGraph
end

---@public
function TaskBaseClass:SendEventToGraph(InEvent)
    local graph = self:GetTaskGraph()
    if not graph then
        return
    end
    graph:TriggerEvent(InEvent)
end

---@public
function TaskBaseClass:GetTaskOwner()
    return self.__Owner
end

return TaskBaseClass