

log.dev('================Goap Example================')

local agent = class.new 'GAgent' () ---@as GAgent
agent.Memory:SetState('Hunger', true)
agent.Memory:SetState('Apple', false)

local goal1 = class.new'GGoal'('no hunger', {Hunger = false}) ---@as GGoal
local goal2 = class.new'GGoal'('fight', {Peace = false}) ---@as GGoal
agent:AddGoal(goal1)
agent:AddGoal(goal2)

local actionEat1 = class.new'GAction'('EatApple', {Hunger = true, Apple = true}, {Hunger = false}, 1) ---@as GAction
local actionEat2 = class.new'GAction'('BuyApple', {Apple = false}, {Apple = true}, 1) ---@as GAction

agent:SetActions({actionEat1, actionEat2})

agent:Plan()
log.dev('result plan:')
if agent.CurPlan then
    for k, v in pairs(agent.CurPlan) do
        log.dev('   ', k, v)
    end
end

log.dev('================Goap Example================')