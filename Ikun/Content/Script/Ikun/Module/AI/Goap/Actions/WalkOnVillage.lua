
---
---@brief   在村子里走走
---@author  zys
---@data    Fri Oct 03 2025 00:02:20 GMT+0800 (中国标准时间)
---

local NavMoveBehav = require('Ikun/Module/Nav/NavMoveBehav')

---@class WalkOnVillage: GAction
---@field NavMoveBehav NavMoveBehav
---@field OwnerAgent GAgent
local WalkOnVillage = class.class'WalkOnVillage' : extends 'GAction'{}

---@override
function WalkOnVillage:ActionStart(Agent)
    class.GAction.ActionStart(self, Agent)
    self.OwnerAgent = Agent
    local navMoveBehav = class.new 'NavMoveBehav' (Agent:GetAgentRole().Avatar, 5) ---@as NavMoveBehav
    self.NavMoveBehav = navMoveBehav
    
    self:_GoToVillageRandom()
    self.EndHour = TimeMgr.Hour + 2
end

---@override
function WalkOnVillage:ActionTick(_, DeltaTime)
    if TimeMgr.Hour == self.EndHour then
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
        self.NavMoveBehav = nil
    end
end

---@private
function WalkOnVillage:_GoToVillageRandom()
    if not self.NavMoveBehav then
        return
    end
    local avatar = self.OwnerAgent:GetAgentRole().Avatar
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
    async_util.delay(self.OwnerAgent:GetAgentRole().Avatar, 3, self._GoToVillageRandom, self)
end

function WalkOnVillage:_OnMoveSuceesss()
    async_util.delay(self.OwnerAgent:GetAgentRole().Avatar, 3, self._GoToVillageRandom, self)
end

return WalkOnVillage