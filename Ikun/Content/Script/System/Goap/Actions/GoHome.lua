
---
---@brief   回家
---@author  zys
---@data    Fri Oct 03 2025 13:25:07 GMT+0800 (中国标准时间)
---

---@class GoHomeAction: GAction
local GoHomeAction = class.class'GoHomeAction':extends'GAction'{}

---@override
function GoHomeAction:ActionStart(Agent)
    class.GAction.ActionStart(self, Agent)

    local home = Agent:GetAgentRole().HoldLocation:GetHomeLocation()
    if not home then
        log.error('GoHomeAction:ActionStart()', '无家可归!!!')
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
    local loc = home.LocationAvatar:GetHousePosition()
    local navMoveBehav = class.new 'NavMoveBehav' (Agent:GetAgentRole().Avatar, 5) ---@as NavMoveBehav
    navMoveBehav:NewMoveToTask(loc, 600, tb)
    self.NavMoveBehav = navMoveBehav
end

---@override
function GoHomeAction:ActionTick(Agent, DeltaTime)
    self.NavMoveBehav:TickMove(DeltaTime)
end

---@private
function GoHomeAction:_OnMoveSuceesss()
    self:EndAction(true)
end

---@private
function GoHomeAction:_OnMoveFailed()
    self:EndAction(false)

    log.error('zys: todo tp to home')
end

return GoHomeAction