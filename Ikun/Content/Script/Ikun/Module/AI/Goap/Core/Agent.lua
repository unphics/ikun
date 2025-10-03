
---
---@brief   进行决策的单位的代理, 外部设置目标
---@todo    将AI委托给Goap中的Agent, 此处还缺少执行器或等效逻辑
---@author  zys
---@data    Sat Sep 27 2025 20:25:28 GMT+0800 (中国标准时间)
---

local initState = {
    IsSleeping = true,
    AtHome = true,
    AtVillage = true,
    Morning = true,
    IsWorking = false,
    IsHungry = true, ---@todo zys
}

---@class GoapConfig
---@field GoapKey string
---@field Desc string
---@field Sensors string[]
---@field DailyGoals string[]
---@field InitActions string[]

---@class GAgent
---@field _OwnerRole RoleClass
---@field Memory GMemory
---@field ActionList GAction[] 所有可用行为
---@field SensorList GSensor[]
---@field GoalList GGoal[] 所有可选目标
---@field Executor GExecutor
local GAgent = class.class'GAgent' {}

function GAgent:ctor(OwnerRole)
    self._OwnerRole = OwnerRole
    self.Memory = class.new 'GMemory' () ---@as GMemory
    self.Executor = class.new'GExecutor'(self)
    self.SensorList = {}
    self.ActionList = {}
    self.GoalList = {}

    -- goap key
    local goapKey = RoleMgr:GetRoleConfig(self._OwnerRole:GetRoleCfgId()).GoapKey
    local goapConfig = ConfigMgr:GetConfig('GoapConfig')[goapKey] ---@as GoapConfig

    -- init state
    for state, value in pairs(initState) do
        self.Memory:SetState(state, value)
    end

    -- init sensor
    for _, sensorName in ipairs(goapConfig.Sensors) do
        local sensor = class.new(sensorName)(self)
        table.insert(self.SensorList, sensor)
    end
    
    -- init action
    local allAction = ConfigMgr:GetConfig('Action') ---@as table<string, ActionConfig>
    for _, action in ipairs(goapConfig.InitActions) do
        local config = allAction[action]
        local preconditions = goap.util.make_states_from_config(config.Preconditions)
        local effects = goap.util.make_states_from_config(config.Effects)
        local action = class.new(config.ActionTemplate)(config.ActionName, preconditions, effects, config.Cost) ---@as GAction
        table.insert(self.ActionList, action)
    end
end

function GAgent:LateAtNight()
    self.Memory:SetState('MonringWalk', false)
    self.Memory:SetState('HasDinner', false)
    
    local goapKey = RoleMgr:GetRoleConfig(self._OwnerRole:GetRoleCfgId()).GoapKey
    local goapConfig = ConfigMgr:GetConfig('GoapConfig')[goapKey] ---@as GoapConfig
    local allGoal = ConfigMgr:GetConfig('Goal')
    for i, name in ipairs(goapConfig.DailyGoals) do
        local config = allGoal[name] ---@as GoalConfig
        local desiredStates = goap.util.make_states_from_config(config.DesiredState)
        local goal = class.new'GGoal'(config.GoalName, desiredStates) ---@as GGoal
        self:AddGoal(goal)
    end
    if not self.Executor:IsExecuting() then
        self:MakePlan()
    end
end

---@public
---@param DeltaTime number
function GAgent:TickAgent(DeltaTime)
    ---@param sensor GSensor
    for _, sensor in ipairs(self.SensorList) do
        sensor:TickSensor(DeltaTime)
    end
    self.Executor:TickExecutor(DeltaTime)
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

---@param Goal GGoal
function GAgent:FinishPlan(Goal, Plan)
    for i = 1, #self.GoalList do
        if self.GoalList[i] == Goal then
            table.remove(self.GoalList, i)
            break
        end
    end
    self:MakePlan()
end

---@public 找出有效的目标列表, 从第一个目标开始找出一个有方法达到的目标
function GAgent:MakePlan()
    local validGoals = {} ---@type GGoal[]
    for _, goal in ipairs(self.GoalList) do
        ---@rule 有效判定: 自己有这个状态
        -- if goap.util.is_key_cover(self.Memory:GetStates(), goal.DesiredStates) then
            table.insert(validGoals, goal)
        -- end
    end
    if #validGoals == 0 then
        log.dev('啥都干不了!!!')
        self.Memory:Print()
    end
    for _, goal in ipairs(validGoals) do
        local cur = self.Memory:GetStates()
        local plan = goap.planner.Plan(cur, goal, self.ActionList)
        if plan then
            self.Memory:Print()
            self.Executor:ExecNewPlan(goal, plan)
            break
        else
            log.dev('该目标没有方法执行, 请检查配置表', goal.Name, TimeMgr:GetCurTimeDisplay())
            self.Memory:Print()
        end
    end
end

return GAgent