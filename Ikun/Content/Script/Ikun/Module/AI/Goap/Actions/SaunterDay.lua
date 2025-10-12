
---
---@brief   闲逛一整天
---@author  zys
---@data    Sun Oct 12 2025 13:49:48 GMT+0800 (中国标准时间)
---

---@class SaunterDayAction: GAction
---@field OwnerAgent GAction
---@field NavMoveBehav NavMoveBehav
local SaunterDayAction = class.class'SaunterDayAction' :extends'GAction' {}

---@override
function SaunterDayAction:ActionStart(Agent)
    class.GAction.ActionStart(self, Agent)

    self.OwnerAgent = Agent
    self.NavMoveBehav = class.new'NavMoveBehav'(rolelib.chr(Agent), 5)
    if not self.NavMoveBehav then
        log.error('WalkOnVillage:ActionStart() 创建NavMoveBehav失败!!')
        self:EndAction(false)
        return
    end
    self:_SaunterRandom()
end

---@override
function SaunterDayAction:ActionTick(Agent, DeltaTime)
    if self.NavMoveBehav then
        self.NavMoveBehav:TickMove(DeltaTime)
    end
end

---@override
function SaunterDayAction:ActionEnd(Agent, bSuccess)
    if self.NavMoveBehav then
        self.NavMoveBehav:CancelMove()
        self.NavMoveBehav = nil
    end
end

---@private
function SaunterDayAction:_SaunterRandom()
    if not self.NavMoveBehav then
        self:EndAction(false)
        return
    end

    local avatar = rolelib.chr(self.OwnerAgent)
    if not avatar then
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
    local bResult, pos = class.NavMoveData.RandomNavPointInRadius(avatar, avatar:K2_GetActorLocation(),3000)
    if bResult then
        self.NavMoveBehav:NewMoveToTask(pos, 300, tb)
    else
        self:EndAction(true)
        return
    end
end

---@private
function SaunterDayAction:_OnMoveFailed()
    async_util.delay(self.OwnerAgent:GetAgentRole().Avatar, 10, self._SaunterRandom, self)
end

---@private
function SaunterDayAction:_OnMoveSuceesss()
    async_util.delay(self.OwnerAgent:GetAgentRole().Avatar, 10, self._SaunterRandom, self)
end

return SaunterDayAction