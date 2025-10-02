
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
---@field Executor GExecutor
local GAgent = class.class'GAgent' {}

function GAgent:ctor(OwnerRole)
    self._OwnerRole = OwnerRole
    self.Memory = class.new 'GMemory' () ---@as GMemory
    self.Executor = class.new'GExecutor'(self)
    self.SensorList = {}
    self.ActionList = {}
    self.GoalList = {}

    async_util.delay(self._OwnerRole.Avatar, 1, function()
        ---@todo zys 初始化RoleAction
        local allAction = ConfigMgr:GetConfig('Action')
        ---@param config ActionConfig
        for key, config in pairs(allAction) do
            local action = class.new(config.ActionTemplate)(config.ActionName, goap.util.make_states_from_config(config.Preconditions), goap.util.make_states_from_config(config.Effects), config.Cost)
            table.insert(self.ActionList, action)
        end

        ---@todo zys 初始化RoleSensor
        local default = class.new'DefaultSensor'(self)
        table.insert(self.SensorList, default)

        self.Memory:SetState('IsSleeping', true)
        self.Memory:SetState('AtVillage', true)
        self.Memory:SetState('Morning', true)
        local allGoal = ConfigMgr:GetConfig('Goal')
        local config1 = allGoal['Getup']
        local goal1 = class.new'GGoal'(config1.GoalName, goap.util.make_states_from_config(config1.DesiredState)) ---@as GGoal
        -- self:AddGoal(goal1)
        local config2 = allGoal['MorningWalk']
        local goal2 = class.new'GGoal'(config2.GoalName, goap.util.make_states_from_config(config2.DesiredState)) ---@as GGoal
        self:AddGoal(goal2)
        self:Plan()
    end)
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

---@public 找出有效的目标列表, 从第一个目标开始找出一个有方法达到的目标
function GAgent:Plan()
    local validGoals = {} ---@type GGoal[]
    for _, goal in ipairs(self.GoalList) do
        ---@rule 有效判定: 自己有这个状态
        -- if goap.util.is_key_cover(self.Memory:GetStates(), goal.DesiredStates) then
            table.insert(validGoals, goal)
        -- end
    end
    if #validGoals == 0 then
        log.dev('啥都干不了!!!')
    end
    for _, goal in ipairs(validGoals) do
        local cur = self.Memory:GetStates()
        local plan = goap.planner.Plan(cur, goal, self.ActionList)
        if plan then
            self.Executor:ExecNewPlan(goal, plan)
        else
            log.dev('该目标没有方法执行, 请检查配置表', goal.Name)
        end
    end
end

return GAgent