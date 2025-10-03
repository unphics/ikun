
---
---@brief   睡觉
---@author  zys
---@data    
---

---@class SleepAction: GAction
local SleepAction = class.class'SleepAction': extends 'GAction' {}

function SleepAction:ActionTick(Agent, DeltaTime)
    if TimeMgr.Hour == 7 then
        self:EndAction(true)
    end
end

return SleepAction