
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

---@class AgentPartInterface
---@field _OwnerAgent GAgent

---@class GoapConfig
---@field GoapKey string
---@field Desc string
---@field Sensors string[]
---@field DailyGoals string[]
---@field InitActions string[]

---@class GAgent
---@field _OwnerRole RoleBaseClass
---@field Memory GMemory
---@field ActionList GAction[] 所有可用行为
---@field _SensorList GSensor[]
---@field _GoalList GGoal[] 所有可选目标
---@field _Executor GExecutor
local GAgent = class.class'GAgent' {}

---@public
---@param InOwnerRole RoleBaseClass
function GAgent:ctor(InOwnerRole)
    self._OwnerRole = InOwnerRole
    self.Memory = class.new 'GMemory' (self) ---@as GMemory
    self._Executor = class.new'GExecutor'(self)
    self._SensorList = {}
    self.ActionList = {}
    self._GoalList = {}

    -- goap key
    local goapKey = RoleMgr:GetRoleConfig(self._OwnerRole:GetRoleCfgId()).GoapKey
    local goapConfig = ConfigMgr:GetConfig('GoapConfig')[goapKey] ---@as GoapConfig

    -- init state
    for state, value in pairs(initState) do
        self.Memory:SetState(state, value)
    end

    -- init sensor
    if goapConfig.Sensors then
        for _, sensorName in ipairs(goapConfig.Sensors) do
            local sensor = class.new(sensorName)(self)
            table.insert(self._SensorList, sensor)
        end
    end
    
    -- init action
    if goapConfig.InitActions and type(goapConfig.InitActions) == "table" then
        local allAction = ConfigMgr:GetConfig('Action') ---@as table<string, ActionConfig>
        for _, action in ipairs(goapConfig.InitActions) do
            local config = allAction[action]
            if not class[config.ActionTemplate] then
                log.error('存在未实现的ActionTemplate', config.ActionTemplate)
                goto continue
            end
            local preconditions = goap.util.make_states_from_config(config.Preconditions)
            local effects = goap.util.make_states_from_config(config.Effects)
            local action = class.new(config.ActionTemplate)(self, config.ActionName, preconditions, effects, config.Cost) ---@as GAction
            table.insert(self.ActionList, action)
            ::continue::
        end
    end

    -- GoapConfig环节的log
    log.info(string.format('角色Agent初始化, name=%s, goap=%s, chr=%s, rolecfg=%i, sensor.len=%i, action.len=%i', 
        InOwnerRole:RoleName(), goapKey, obj_util.dispname(rolelib.chr(InOwnerRole)), 
        InOwnerRole:GetRoleId(), #self._SensorList, #self.ActionList))
end

function GAgent:LateAtNight()
    self.Memory:SetState('MonringWalk', false)
    self.Memory:SetState('HasDinner', false)
    self.Memory:SetState('GainResourceDaily', false)
    self.Memory:SetState('IsHungry', true)
    
    local goapKey = RoleMgr:GetRoleConfig(self._OwnerRole:GetRoleCfgId()).GoapKey
    local goapConfig = ConfigMgr:GetConfig('GoapConfig')[goapKey] ---@as GoapConfig
    local allGoal = ConfigMgr:GetConfig('Goal')
    local strGoal = ''
    if goapConfig.DailyGoals then
        for i, name in ipairs(goapConfig.DailyGoals) do
            local config = allGoal[name] ---@as GoalConfig
            if not config then
                log.error('GAgent:LateAtNight', 'invalid goal', name)
                goto continue
            end
            local desiredStates = goap.util.make_states_from_config(config.DesiredState)
            local goal = class.new'GGoal'(config.GoalName, desiredStates) ---@as GGoal
            self:AddGoal(goal)
            strGoal = strGoal..config.GoalName..'|'
            ::continue::
        end
    end
    log.info('角色晚上更新', rolelib.role(self):RoleName(), strGoal)
    if not self._Executor:IsExecuting() then
        self:MakePlan()
    end
end

---@public
---@param DeltaTime number
function GAgent:TickAgent(DeltaTime)
    ---@param sensor GSensor
    for _, sensor in ipairs(self._SensorList) do
        sensor:TickSensor(DeltaTime)
    end
    self._Executor:TickExecutor(DeltaTime)
end

---@public 添加可选目标
---@param Goal GGoal
---@param Priority integer 优先级
function GAgent:AddGoal(Goal, Priority)
    local length = #self._GoalList
    Priority = Priority or length
    if (Priority > length) or length == 0 then
        table.insert(self._GoalList, Goal)
    else
        table.insert(self._GoalList, Priority, Goal)
    end
end

---@public [Init] 赋予所有可用行动
---@param Actions GAction[]
function GAgent:SetActions(Actions)
    self.ActionList = Actions
end

---@param Goal GGoal
function GAgent:FinishPlan(Goal, Plan)
    for i = 1, #self._GoalList do
        if self._GoalList[i] == Goal then
            table.remove(self._GoalList, i)
            break
        end
    end
    self:MakePlan()
end

---@public 找出有效的目标列表, 从第一个目标开始找出一个有方法达到的目标
function GAgent:MakePlan()
    local validGoals = {} ---@type GGoal[]
    for _, goal in ipairs(self._GoalList) do
        ---@rule 有效判定: 自己有这个状态
        -- if goap.util.is_key_cover(self.Memory:GetStates(), goal.DesiredStates) then
            table.insert(validGoals, goal)
        -- end
    end
    if #validGoals == 0 then
        log.warn(rolelib.role(self):RoleName(), '啥都干不了!!!')
        self.Memory:Print()
    end
    for _, goal in ipairs(validGoals) do
        local cur = self.Memory:GetStates()
        local plan = goap.planner.Plan(cur, goal, self.ActionList)
        if plan then
            self.Memory:Print()
            self._Executor:ExecNewPlan(goal, plan)
            break
        else
            log.error(rolelib.role(self):RoleName(), '该目标没有方法执行', goal.Name, TimeMgr:GetCurTimeDisplay())
            self:PrintAllAction()
            self.Memory:Print(true)
        end
    end
end

---@public
---@return RoleBaseClass
function GAgent:GetAgentRole()
    return self._OwnerRole
end

---@public
function GAgent:PrintAllAction()
    local str = '所有可用行动: '
    for _, action in ipairs(self.ActionList) do
        str = str..action:GetActionName()..'|'
    end
    log.info(rolelib.role(self):RoleName(), str)
end

return GAgent