
---
---@brief   下一个行为
---@author  zys
---@data    Wed Jun 18 2025 22:31:19 GMT+0800 (中国标准时间)
---

---@class LTask_NextBehav : LTask
local LTask_NextBehav = class.class 'LTask_NextBehav' : extends 'LTask' {
--[[public]]
    ctor = function()end,
    OnInit = function()end,
    OnUpdate = function()end,
--[[private]]
}
function LTask_NextBehav:ctor(NodeDispName)
    class.LTask.ctor(self, NodeDispName)
end
function LTask_NextBehav:OnInit()
    
end
function LTask_NextBehav:OnUpdate()
end