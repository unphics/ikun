
---
---@brief   等待到晚上
---@author  zys
---@data    Fri Oct 10 2025 00:50:36 GMT+0800 (中国标准时间)
---

---@class WaitEveningAction: GAction
local WaitEveningAction = class.class'WaitEveningAction' : extends 'GAction' {}

---@private
function WaitEveningAction:ActionTick(Agent, DeltaTime)
    if TimeMgr.Hour == 20 then
        self:EndAction(true)
    end
end

return WaitEveningAction