
---
---@brief   睡觉
---@author  zys
---@data    Fri Oct 10 2025 00:49:19 GMT+0800 (中国标准时间)
---

---@class SleepAction: GAction
local SleepAction = class.class'SleepAction': extends 'GAction' {}

function SleepAction:ActionTick(Agent, DeltaTime)
    if TimeMgr.Hour == 7 then
        self:EndAction(true)
    end
end

return SleepAction