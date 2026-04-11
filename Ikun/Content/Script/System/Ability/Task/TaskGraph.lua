

local Class3 = require("Core/Class/Class3")
local log = require("Core/Log/log")
local Delegate = require("Core/Delegate")

---@class TaskGraphClass
local TaskGraphClass = Class3.Class("TaskGraph")

function TaskGraphClass:Ctor(InOwner)
    self._Owner = InOwner
end

function TaskGraphClass:BeginTaskGraph()
end

function TaskGraphClass:TickTaskGraph()
end

function TaskGraphClass:EndTaskGraph()
end

function TaskGraphClass:AddDelayTask()
end

function TaskGraphClass:AddSequenceTask()
end

function TaskGraphClass:AddWaitEventTask()
end

function TaskGraphClass:IsAnyTaskRunning()
end

return TaskGraphClass