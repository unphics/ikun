
---
---@brief   在村子里走走
---@author  zys
---@data    Fri Oct 03 2025 00:02:20 GMT+0800 (中国标准时间)
---

local NavMoveBehav = require('Ikun/Module/Nav/NavMoveBehav')

---@class WalkOnVillage: GAction
local WalkOnVillage = class.class'WalkOnVillage' : extends 'GAction'{}

---@override
function WalkOnVillage:ActionStart(Agent)
    self.Agent = Agent
    local navMoveBehav = class.new 'NavMoveBehav' (Agent._OwnerRole.Avatar, 5) ---@as NavMoveBehav
    self.NavMoveBehav = navMoveBehav
    self.WalkTime = 300
    self:_GoToVillageRandom()
end

---@override
function WalkOnVillage:ActionTick(Agent, DeltaTime)
    self.WalkTime = self.WalkTime - DeltaTime
    if self.WalkTime < 0 then
        self:EndAction(true)
    end
    if self.NavMoveBehav then
        self.NavMoveBehav:TickMove(DeltaTime)
    end
end

---@override
function WalkOnVillage:ActionEnd()
    if self.NavMoveBehav then
        self.NavMoveBehav:CancelMove()
    end
end

---@private
function WalkOnVillage:_GoToVillageRandom()
    if not self.NavMoveBehav then
        return
    end
    local avatar = self.Agent._OwnerRole.Avatar
    local bresult, loc = class.NavMoveData.RandomNavPointInRadius(avatar, avatar:K2_GetActorLocation(), 3000)
    if bresult then
        local tb = {} ---@type NavMoveBehavCallbackInfo
        tb.This = self
        tb.OnNavMoveArrived = self._OnMoveSuceesss
        tb.OnNavMoveCancelled = self._OnMoveFailed
        tb.OnNavMoveLostTarget = self._OnMoveFailed
        tb.OnNavMoveStuck = self._OnMoveFailed
        self.NavMoveBehav:NewMoveToTask(loc, 300, tb)
    end
end

function WalkOnVillage:_OnMoveFailed()
    async_util.delay(self.Agent._OwnerRole.Avatar, 3, self._GoToVillageRandom, self)
end

function WalkOnVillage:_OnMoveSuceesss()
    async_util.delay(self.Agent._OwnerRole.Avatar, 3, self._GoToVillageRandom, self)
end

return WalkOnVillage