
---
---@brief   目标
---@author  zys
---@data    Sat Sep 27 2025 20:43:24 GMT+0800 (中国标准时间)
---

---@class GoalConfig
---@field GoalKey string
---@field GoalName string
---@field GoalDesc string
---@field DesiredState table<string, string>
---@field Priority integer

---@class GGoal
---@field Name string
---@field DesiredStates table<string, boolean> <状态名,期望状态>
local GGoal = class.class'GGoal' {
    Name = nil,
    DesiredStates = nil
}
function GGoal:ctor(Name, States)
    self.Name = Name or 'Goal'
    self.DesiredStates = States or {}
end