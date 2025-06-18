
---
---@brief   等待移动到
---@author  zys
---@data    Wed Jun 18 2025 23:39:53 GMT+0800 (中国标准时间)
---

---@class LTask_WaitMoveArrived : LTask
local LTask_WaitMoveArrived = class.class 'LTask_WaitMoveArrived' : extends 'LTask' {
--[[public]]
    ctor = function()end
}
function LTask_WaitMoveArrived:ctor(NodeDispName)
    class.LTask.ctor(self, NodeDispName)
end
function LTask_WaitMoveArrived:OnInit()
end
function LTask_WaitMoveArrived:OnUpdate(DeltaTime)
end