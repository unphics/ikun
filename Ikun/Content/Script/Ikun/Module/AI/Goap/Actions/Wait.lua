
---
---@brief   等待
---@author  zys
---@data    Thu Oct 02 2025 21:47:54 GMT+0800 (中国标准时间)
---

---@class WaitAction: GAction
local WaitAction = class.class'WaitAction': extends 'GAction' {}

function WaitAction:ActionStart(Agent)
    class.GAction.ActionStart(self, Agent)
    self.WaitTime = 3
end

function WaitAction:ActionTick(Agent, DeltaTime)
    if self.WaitTime then
        self.WaitTime = self.WaitTime - DeltaTime
        if self.WaitTime < 0 then
            self:EndAction(true)
        end
    end
end

function WaitAction:ActionEnd(Agent, bSucceed)
end

return WaitAction