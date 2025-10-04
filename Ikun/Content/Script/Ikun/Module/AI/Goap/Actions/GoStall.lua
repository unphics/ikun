
---
---@brief   去摊位
---@author  zys
---@data    Sat Oct 04 2025 15:03:32 GMT+0800 (中国标准时间)
---

---@class GoStallAction: GAction
local GoStallAction = class.class'GoStallAction':extends'GAction'{}

---@override
function GoStallAction:ActionStart(Agent)
    class.GAction.ActionStart(self, Agent)
    local navMoveBehav = class.new 'NavMoveBehav' (Agent:GetAgentRole().Avatar, 5) ---@as NavMoveBehav
    local home = Agent:GetAgentRole().HoldLocation:GetStallLocation()
    if not home then
        log.error('没有摊位!!!')
        self:EndAction(false)
        return
    end
    local loc = home.LocationAvatar:GetStallPosition()
    local tb = {} ---@type NavMoveBehavCallbackInfo
    tb.This = self
    tb.OnNavMoveArrived = self._OnMoveSuceesss
    tb.OnNavMoveCancelled = self._OnMoveFailed
    tb.OnNavMoveLostTarget = self._OnMoveFailed
    tb.OnNavMoveStuck = self._OnMoveFailed
    navMoveBehav:NewMoveToTask(loc, 600, tb)
    self.NavMoveBehav = navMoveBehav
end

---@override
function GoStallAction:ActionTick(Agent, DeltaTime)
    self.NavMoveBehav:TickMove(DeltaTime)
end

---@private
function GoStallAction:_OnMoveSuceesss()
    self:EndAction(true)
end

---@private
function GoStallAction:_OnMoveFailed()
    self:EndAction(false)
    log.dev('todo tp to home')
end

return GoStallAction