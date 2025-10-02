
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
---@field SensorList GSensor[]
---@field GoalList GGoal[] 所有可选目标
---@field CurGoal GGoal 当前设定的目标
---@field CurPlan string[] 当前设定的计划
local GAgent = class.class'GAgent' {}

function GAgent:ctor(OwnerRole)
    self._OwnerRole = OwnerRole
    self.Memory = class.new 'GMemory' () ---@as GMemory
    self.SensorList = {}
    self.ActionList = {}
    self.GoalList = {}
    self.CurGoal = nil
    self.CurPlan = nil

    local allGoal = ConfigMgr:GetConfig('Goal')
    do
        self.Memory:SetState('IsSleeping', true)
        self.Memory:SetState('Morning', true)
        local config = allGoal['Getup']
        local goal = class.new'GGoal'(config.GoalName, goap.util.make_states_from_config(config.DesiredState)) ---@as GGoal
        self:AddGoal(goal)
    end
    do
        self.Memory:SetState('AtVillage', true)
        local config = allGoal['MorningWalk']
        local goal = class.new'GGoal'(config.GoalName, goap.util.make_states_from_config(config.DesiredState)) ---@as GGoal
        self:AddGoal(goal)
    end
    do
        self.Memory:SetState('IsHungry', true)
        local config = allGoal['HaveBreakfast']
        local goal = class.new'GGoal'(config.GoalName, goap.util.make_states_from_config(config.DesiredState)) ---@as GGoal
        self:AddGoal(goal)
    end
    do
        local config = allGoal['WorkAtStall']
        local goal = class.new'GGoal'(config.GoalName, goap.util.make_states_from_config(config.DesiredState)) ---@as GGoal
        self:AddGoal(goal)
    end
    do
        local config = allGoal['ReturnHome']
        local goal = class.new'GGoal'(config.GoalName, goap.util.make_states_from_config(config.DesiredState)) ---@as GGoal
        self:AddGoal(goal)
    end
    
    self.Memory:Print()

    local allAction = ConfigMgr:GetConfig('Action')
    ---@param config ActionConfig
    for key, config in pairs(allAction) do
        local action = class.new'GAction'(config.ActionName, goap.util.make_states_from_config(config.Preconditions), goap.util.make_states_from_config(config.Effects), config.Cost)
        table.insert(self.ActionList, action)
    end
    
    local sensor = class.new'GSensor'(self)
    table.insert(self.SensorList, sensor)
    self:Plan()
end

---@public
---@param DeltaTime number
function GAgent:TickAgent(DeltaTime)
    ---@param sensor GSensor
    for _, sensor in ipairs(self.SensorList) do
        sensor:TickSensor(DeltaTime)
    end

    -- self.Memory:Print()
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
function GAgent:Plan()
    local validGoals = {} ---@type GGoal[]
    for _, goal in ipairs(self.GoalList) do
        -- 有效判定: 自己有这个状态
        -- if goap.util.is_key_cover(self.Memory:GetStates(), goal.DesiredStates) then
            table.insert(validGoals, goal)
        -- end
    end
    if #validGoals == 0 then
        log.dev('啥都干不了!!!')
    end
    for _, goal in ipairs(validGoals) do
        -- local name = goal.Name
        -- if name == '晨间散步' then
        --     local a = 1
        -- end
        local cur = self.Memory:GetStates()
        local plan = goap.planner.Plan(cur, goal, self.ActionList)
        if plan then
            self.CurGoal = goal
            self.CurPlan = plan
            log.dev('得出plan-->', goal.Name)
            for _, str in ipairs(self.CurPlan) do
                log.dev('   ',str)
            end
        else
            log.dev('该目标没有方法执行, 请检查配置表', goal.Name)
        end
    end
end


return GAgent