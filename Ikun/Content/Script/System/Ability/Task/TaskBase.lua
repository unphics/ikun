

local Class3 = require("Core/Class/Class3")
local log = require("Core/Log/log")
local Delegate = require("Core/Delegate")

---@class TaskBaseClass
local TaskBaseClass = Class3.Class("TaskBaseClass")

function TaskBaseClass:Ctor(InOwner)
end

function TaskBaseClass:BeginTask()
end

function TaskBaseClass:EndTask()
end

function TaskBaseClass:SetTaskGraph()
end

function TaskBaseClass:GetTaskGraph()
end

function TaskBaseClass:SendEventToGraph()
end

return TaskBaseClass