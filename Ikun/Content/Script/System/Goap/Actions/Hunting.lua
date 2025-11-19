
---
---@brief   打猎
---@author  zys
---@data    Sat Oct 04 2025 15:26:15 GMT+0800 (中国标准时间)
---

---@class HuntingAction: GAction
---@field NavMoveBehav NavMoveBehav?
local HuntingAction = class.class'HuntingAction': extends 'GAction' {}

---@override
function HuntingAction:ActionStart(Agent)
    class.GAction.ActionStart(self, Agent)

    local avatar = rolelib.role(Agent).Avatar
    local navMoveBehav = class.new'NavMoveBehav'(avatar, 5)
    local bResult, loc = class.NavMoveData.RandomNavPointInRadius(avatar, avatar:K2_GetActorLocation(), 30000)
    if not bResult then
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
        OnMoveTaskEnd = nil,
    } 
    navMoveBehav:NewMoveToTask(loc, 300, tb)
    self.NavMoveBehav = navMoveBehav
end

---@override
function HuntingAction:ActionTick(Agent, DeltaTime)
    if TimeMgr.Hour == 18 then
        self:EndAction(true)
    end
    if self.NavMoveBehav then
        self.NavMoveBehav:TickMove(DeltaTime)
    end
end

---@override
function HuntingAction:ActionEnd(Agent, bSucceed)
    if self.NavMoveBehav then
        self.NavMoveBehav:CancelMove()
    end
end

---@private
function HuntingAction:_OnMoveSuceesss()
    if self.NavMoveBehav then
        self.NavMoveBehav:CancelMove()
    end
end

---@private
function HuntingAction:_OnMoveFailed()
    self:EndAction(false)
end

return HuntingAction