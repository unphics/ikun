
---
---@brief 团队移动
---@author zys
---@data Fri Apr 25 2025 00:07:36 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LTask_TeamMove : LTask_AiMoveBase
local LTask_TeamMove = class.class 'LTask_TeamMove' : extends 'LTask_AiMoveBase' {

}
function LTask_TeamMove:OnTerminate()
    self.Blackboard:SetBBValue(BBKeyDef.MoveTarget, nil)
    local OwnerRole = self.Chr:GetRole()
    OwnerRole.Team.TeamMove:OnArrived(OwnerRole)
end

return LTask_TeamMove