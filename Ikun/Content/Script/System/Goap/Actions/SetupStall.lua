
---
---@brief   摆摊工作卖东西
---@author  zys
---@data    Fri Oct 10 2025 00:49:19 GMT+0800 (中国标准时间)
---

---@class SetupStallAction: GAction
local SetupStallAction = class.class'SetupStallAction': extends 'GAction' {}

---@private
function SetupStallAction:ActionTick(Agent, DeltaTime)
    if TimeMgr.Hour == 18 then
        self:EndAction(true)
    end
end

return SetupStallAction