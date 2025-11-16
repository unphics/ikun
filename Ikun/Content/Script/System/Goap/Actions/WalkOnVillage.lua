
---
---@brief   早晨在村子里走走
---@author  zys
---@data    Fri Oct 03 2025 00:02:20 GMT+0800 (中国标准时间)
---

---@class WalkOnVillage: GAction
---@field NavMoveBehav NavMoveBehav
---@field OwnerAgent GAgent
local WalkOnVillage = class.class'WalkOnVillage' : extends 'GAction'{}

---@override
function WalkOnVillage:ActionStart(Agent)
    class.GAction.ActionStart(self, Agent)

    self.OwnerAgent = Agent
    self.EndHour = TimeMgr.Hour + 2
    self.NavMoveBehav = class.new 'NavMoveBehav' (Agent:GetAgentRole().Avatar, 5) ---@as NavMoveBehav
    if not self.NavMoveBehav then
        log.error('WalkOnVillage:ActionStart() 创建NavMoveBehav失败!!')
        self:EndAction(false)
        return
    end
    
    self:_GoToVillageRandom()
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
        self:EndAction(false)
    end
    
    local role = rolelib.role(self.OwnerAgent)
    if not role then
        self:EndAction(false)
        return
    end

    local home = role.HoldLocation:GetHomeLocation() ---@type LocationClass?
    if not home then
        self:EndAction(false)
        return
    end
    
    local settlement = home:GetBelongSettlement()
    if not settlement then
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
    local pos = settlement:GetRandomWalkPos()
    self.NavMoveBehav:NewMoveToTask(pos, 300, tb)
end

---@private
function WalkOnVillage:_OnMoveFailed()
    async_util.delay(self.OwnerAgent:GetAgentRole().Avatar, 3, self._GoToVillageRandom, self)
end

---@private
function WalkOnVillage:_OnMoveSuceesss()
    async_util.delay(self.OwnerAgent:GetAgentRole().Avatar, 3, self._GoToVillageRandom, self)
end

return WalkOnVillage