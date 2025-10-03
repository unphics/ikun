
---
---@brief   摆摊工作卖东西
---@author  zys
---@data    
---

---@class SetupStallAction: GAction
local SetupStallAction = class.class'SetupStallAction': extends 'GAction' {}

function SetupStallAction:ActionTick(Agent, DeltaTime)
    if TimeMgr.Hour == 18 then
        self:EndAction(true)
    end
end

return SetupStallAction