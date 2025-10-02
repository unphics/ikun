
---
---@brief   执行器
---@author  zys
---@data    Thu Oct 02 2025 21:10:28 GMT+0800 (中国标准时间)
---

---@class GExecutor
---@field _Agent GAgent
---@field CurPlan string[]
---@field CurGoal GGoal
---@field CurAction GAction
---@field _CurActionIdx number
local GExecutor = class.class'GExecutor'{}

---@public
function GExecutor:ctor(Agent)
    self._Agent = Agent
end

---@public
---@param Goal GGoal
function GExecutor:ExecNewPlan(Goal, Plan)
    self.CurGoal = Goal
    self.CurPlan = Plan

    if self.CurAction then
        self.CurAction:ActionCancelled(self._Agent)
        self.CurAction:ActionEnd(self._Agent, false)
    end
    self._CurActionIdx = 1
    for _, action in ipairs(self._Agent.ActionList) do
        if action._ActionName == self.CurPlan[self._CurActionIdx] then
            self.CurAction = action
        end
    end

    local str = ''
    str = str..Goal.Name..' : '
    for _, name in ipairs(Plan or {}) do
        str = str..name..', '
    end
    log.dev('执行器:新计划', str)
end

---@public
function GExecutor:TickExecutor(DeltaTime)
    if self.CurAction then
        if self.CurAction._ActionEnd then
            if self.CurAction._ActionSucceed then
                for state, value in pairs(self.CurAction.Effects) do
                    self._Agent.Memory._State[state] = value
                end
            end
            log.dev('动作完成:', self.CurAction._ActionName)
            self.CurAction:ActionEnd(self._Agent, self.CurAction._ActionSucceed)
            self.CurAction._ActionSucceed = false
            self.CurAction._ActionStart = false
            self.CurAction._ActionEnd = false
            
            self.CurAction = nil
            self._CurActionIdx = self._CurActionIdx + 1
            for _, action in ipairs(self._Agent.ActionList) do
                if action._ActionName == self.CurPlan[self._CurActionIdx] then
                    self.CurAction = action
                end
            end
            if not self.CurAction then
                log.error('Executor: 缺少后续动作')
            end
        elseif not self.CurAction._ActionStart then
            self.CurAction:ActionStart(self._Agent)
            self.CurAction._ActionStart = true
        else
            self.CurAction:ActionTick(self._Agent, DeltaTime)
        end
    end
end

return GExecutor