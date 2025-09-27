
---@class GAgent
---@field _OwnerRole RoleClass
---@field StateList table<string, fun(RoleClass)> <状态名, 查询状态值的函数>
---@field ActionList GAction[] 所有可用行为
---@field GoalList GGoal[] 所有可选目标
---@field CurGoal GGoal 当前设定的目标
---@field CurPlan string[] 当前设定的计划
local GAgent = class.class'GAgent' {}

function GAgent:ctor(OwnerRole)
    self._OwnerRole = OwnerRole
    self.StateList = {}
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

---@public
---@param StateName string
function GAgent:GetCurState(StateName)
    assert(self.StateList[StateName])
    return self.StateList[StateName](self._OwnerRole) or false
end

---@public
---@return table<string, boolean>
function GAgent:GetCurStates()
    local result = {}
    for name, checkerfn in pairs(self.StateList) do
        result[name] = checkerfn(self._OwnerRole) or false
    end
    return result
end

---@param StateName string
---@param Expect boolean
function GAgent:CheckState(StateName, Expect)
    assert(self.StateList[StateName])
    return self.StateList[StateName](self._OwnerRole) == Expect
end

---@param States table<string, fun(RoleClass)>
function GAgent:SetStates(States)
    self.StateList = States
end

---@param Actions GAction[]
function GAgent:SetActions(Actions)
    self.ActionList = Actions
end

---@private 检查BaseStates是否满足TargetStates的要求, 即BaseStates的状态完全覆盖TargetStates的状态
---@param BaseStates table<string, boolean>
---@param TargetStates table<string, boolean>
---@return boolean
function GAgent:_IsStatesEqual(BaseStates, TargetStates)
    for name, value in pairs(TargetStates) do
        if BaseStates[name] ~= value then
            return false
        end
    end
    return true
end

---@private 计算TargetStates与BaseStates之间有多少个状态未满足
---@param BaseStates table<string, boolean>
---@param TargetStates table<string, boolean>
---@return integer
function GAgent:_GetDiffNum(BaseStates, TargetStates)
    local num = 0
    for name, value in pairs(TargetStates) do
        if BaseStates[name] ~= value then
            num = num + 1
        end
    end
    return num
end

---@private 检查CurStates是否满足Action的Preconditions
---@param Action GAction
---@param CurStates table<string, boolean>
function GAgent:_CanPerform(Action, CurStates)
    for name, expect in pairs(Action._Preconditions) do
        if CurStates[name] ~= expect then
            return false
        end
    end
    return true
end

---@private
---@param Action GAction
---@param BaseStates table<string, boolean>
---@return table<string, boolean>
function GAgent:_ApplyEffects(Action, BaseStates)
    for name, value in pairs(Action._Effects) do
        BaseStates[name] = value
    end
    return BaseStates
end

---@public 找出有效的目标列表, 从第一个目标开始找出一个有方法达到的目标
function GAgent:Plan(bDebug)
    local validGoals = {} ---@type GGoal[]
    for _, goal in ipairs(self.GoalList) do
        for name, expect in pairs(goal.States) do
            if not self:CheckState(name, expect) then
                table.insert(validGoals, goal)
            end
        end
    end

    for _, goal in ipairs(validGoals) do
        local plan = class.GPlanner.Plan(self.StateList, goal, error())
        if plan then
            self.CurGoal = goal
            self.CurPlan = plan
        end
    end
end