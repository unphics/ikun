---
---@brief 目标导向的行为规划
---

---@class GAction 动作
local GAction = class.class 'GAction' {
    Name = nil,
    Precondition = nil,
    Effects = nil,
    Cost = nil,
}
function GAction:ctor()
end

---@class GGoal 目标
local GGoal = class.class 'GGoal' {
    Name = nil,
    State = nil,
}
function GGoal:ctor()
end

---@class GPlanner 规划器
---@field Actions GAction[]
---@field Goals GGoal[]
local GPlanner = class.class 'GPlanner' {
    Actions = nil,
    Goals = nil
}
function GPlanner:ctor()
end

---@class GWorldState 世界状态
local GWorldState = class.class 'GWorldState' {
    HasAxe = nil,
    HasWood = nil,
    NearLog = nil,
    NearFirePlace = nil,
}