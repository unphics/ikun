
---
---@brief   等待到傍晚
---@author  zys
---@data    Fri Oct 10 2025 00:50:36 GMT+0800 (中国标准时间)
---

---@class WaitDuskAction: GAction
local WaitDuskAction = class.class'WaitDuskAction' : extends 'GAction' {}

---@private
function WaitDuskAction:ActionTick(Agent, DeltaTime)
    if TimeMgr.Hour == 18 then
        self:EndAction(true)
    end
end

return WaitDuskAction