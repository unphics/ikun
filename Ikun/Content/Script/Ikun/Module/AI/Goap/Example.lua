

log.dev('================Goap Example================')

local agent = class.new 'GAgent' () ---@as GAgent
agent.Memory:SetState('Hunger', true)

local goal1 = class.new'GGoal'('no hunger', {Hunger = false}) ---@as GGoal
local goal2 = class.new'GGoal'('fight', {Peace = false}) ---@as GGoal
agent:AddGoal(goal1)
agent:AddGoal(goal2)

local actionEat = class.new'GAction'('Eat', {Hunger = true}, {Hunger = false}, 1) ---@as GAction

agent:SetActions({actionEat})

local result = agent:Plan()
log.dev('result', result)

log.dev('================Goap Example================')