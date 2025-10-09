
---
---@brief   走去柜台
---@author  zys
---@data    Thu Oct 09 2025 23:36:07 GMT+0800 (中国标准时间)
---

---@class GoCounterAction: GAction
local GoCounterAction = class.class 'GoCounterAction' : extends 'GAction' {}

---@override
function GoCounterAction:ActionStart(InAgent)
    class.GAction.ActionStart(self, InAgent)

    local role = rolelib.role(InAgent)
    if not role then
        self:EndAction(false)
        return
    end

    local counter, location = role.HoldLocation:GetCounter()
    if not counter then
        self:EndAction(false)
        return
    end

    ---@type NavMoveBehavCallbackInfo
    local tb = {
        This = self,
        OnNavMoveArrived = self._OnMoveSuceesss,
        OnNavMoveCancelled = self._OnMoveFailed,
        OnNavMoveLostTarget = self._OnMoveFailed,
        OnNavMoveStuck = self._OnMoveFailed,
    }
    local loc = counter:GetSitePos()
    local navMoveBehav = class.new 'NavMoveBehav' (rolelib.chr(role), 5) ---@as NavMoveBehav
    navMoveBehav:NewMoveToTask(loc, 600, tb)
    self.NavMoveBehav = navMoveBehav
end

---@override
function GoCounterAction:ActionTick(Agent, DeltaTime)
    self.NavMoveBehav:TickMove(DeltaTime)
end

---@override
function GoCounterAction:ActionEnd(Agent, bSuccess)
end

---@private
function GoCounterAction:_OnMoveSuceesss()
    self:EndAction(true)
end

---@private
function GoCounterAction:_OnMoveFailed()

    log.error('zys: todo tp to home')
end

return GoCounterAction