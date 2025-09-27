
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