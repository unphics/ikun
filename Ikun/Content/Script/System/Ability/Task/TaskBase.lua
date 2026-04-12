
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
local TaskBaseClass = Class3.Class("TaskBaseClass")

function TaskBaseClass:Ctor(InOwner)
    self.__Owner = InOwner
end

---@public
function TaskBaseClass:BeginTask()
end

---@public
function TaskBaseClass:EndTask()
    local graph = self:GetTaskGraph()
    if graph then
        graph:NotifyTaskEnd(self)
    end
end

---@public
function TaskBaseClass:TickTask(DeltaTime)
end

---@public
---@return boolean
function TaskBaseClass:IsTaskRunning() -- const
    return false
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
    if not self:GetTaskGraph() then
        return
    end
end

---@public
function TaskBaseClass:GetTaskOwner()
    return self.__Owner
end

return TaskBaseClass