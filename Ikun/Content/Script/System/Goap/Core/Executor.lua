
---
---@brief   执行器
---@author  zys
---@data    Thu Oct 02 2025 21:10:28 GMT+0800 (中国标准时间)
---

---@class GExecutor: AgentPartInterface
---@field _OwnerAgent RoleBaseClass
---@field CurPlan string[]
---@field CurGoal GGoal
---@field CurAction GAction
---@field _CurActionIdx number
local GExecutor = class.class'GExecutor'{}

---@public
function GExecutor:ctor(Agent)
    self._OwnerAgent = Agent
end

---@public
---@param Goal GGoal
function GExecutor:ExecNewPlan(Goal, Plan)
    self.CurGoal = Goal
    self.CurPlan = Plan

    if self.CurAction then
        self.CurAction:ActionCancelled(self._OwnerAgent)
        self.CurAction:ActionEnd(self._OwnerAgent, false)
    end
    self._CurActionIdx = 1
    for _, action in ipairs(self._OwnerAgent.ActionList) do
        if action:GetActionName() == self.CurPlan[self._CurActionIdx] then
            self.CurAction = action
            self.CurAction:ResetActionState()
        end
    end

    local str = ''
    str = str..'<'..Goal.Name..'> '
    for _, name in ipairs(Plan or {}) do
        str = str..name..', '
    end
    log.info(rolelib.role(self):RoleName(),'执行器执行新计划 '.. str)
end

---@public
function GExecutor:TickExecutor(DeltaTime)
    if self.CurAction then
        if self.CurAction:IsActionEnd() then
            if self.CurAction:IsActionSucceed() then
                for state, value in pairs(self.CurAction.Effects) do
                    self._OwnerAgent.Memory:SetState(state, value)
                end
            end
            log.info(rolelib.role(self):RoleName(), '动作完成:', self.CurAction:GetActionName())
            self.CurAction:ActionEnd(self._OwnerAgent, self.CurAction:IsActionSucceed())
            self.CurAction:ResetActionState()
            
            self.CurAction = nil
            self._CurActionIdx = self._CurActionIdx + 1
            for _, action in ipairs(self._OwnerAgent.ActionList) do
                if action:GetActionName() == self.CurPlan[self._CurActionIdx] then
                    self.CurAction = action
                end
            end
            if not self.CurAction then
                log.info(rolelib.role(self):RoleName(), 'Executor: 缺少后续动作')
                self._OwnerAgent:FinishPlan(self.CurGoal, self.CurPlan)
            end
        elseif not self.CurAction:IsActionStart() then
            self.CurAction:ActionStart(self._OwnerAgent)
        else
            self.CurAction:ActionTick(self._OwnerAgent, DeltaTime)
        end 
    end
end

---@public
---@return boolean
function GExecutor:IsExecuting()
    return self.CurAction and true or false
end

return GExecutor