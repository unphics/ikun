
---
---@brief   进行决策的单位的代理, 外部设置目标
---@todo    将AI委托给Goap中的Agent, 此处还缺少执行器或等效逻辑
---@author  zys
---@data    Sat Sep 27 2025 20:25:28 GMT+0800 (中国标准时间)
---

---@class GAgent
---@field _OwnerRole RoleClass
---@field Memory GMemory
---@field ActionList GAction[] 所有可用行为
---@field GoalList GGoal[] 所有可选目标
---@field CurGoal GGoal 当前设定的目标
---@field CurPlan string[] 当前设定的计划
local GAgent = class.class'GAgent' {}

function GAgent:ctor(OwnerRole)
    self._OwnerRole = OwnerRole
    self.Memory = class.new 'GMemory' ()
    self.ActionList = {}
    self.GoalList = {}
    self.CurGoal = nil
    self.CurPlan = nil
end

---@public 设置可选目标
---@param Goals GGoal[]
function GAgent:SetGoals(Goals)
    self.GoalList = Goals
end

---@public 添加可选目标
---@param Goal GGoal
---@param Priority integer 优先级
function GAgent:AddGoal(Goal, Priority)
    local length = #self.GoalList
    Priority = Priority or length
    if Priority >= length then
        table.insert(self.GoalList, Goal)
    else
        table.insert(self.GoalList, Priority, Goal)
    end
end

---@public [Init] 赋予所有可用行动
---@param Actions GAction[]
function GAgent:SetActions(Actions)
    self.ActionList = Actions
end

---@public 找出有效的目标列表, 从第一个目标开始找出一个有方法达到的目标
function GAgent:Plan(bDebug)
    local validGoals = {} ---@type GGoal[]
    for _, goal in ipairs(self.GoalList) do
        -- 有效判定: 自己有这个状态
        if goap.util.is_key_cover(self.Memory:GetStates(), goal.DesiredStates) then
            table.insert(validGoals, goal)
        end
    end
    for _, goal in ipairs(validGoals) do
        local plan = goap.planner.Plan(self.Memory:GetStates(), goal, self.ActionList)
        if plan then
            self.CurGoal = goal
            self.CurPlan = plan
        end
    end

end