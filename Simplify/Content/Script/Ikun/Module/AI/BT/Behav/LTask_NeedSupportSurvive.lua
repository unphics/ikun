
---
---@brief   发布需要支援信号
---@author  zys
---@data    Thu Jun 26 2025 22:58:38 GMT+0800 (中国标准时间)
---

---@class LTask_NeedSupportSurvive : LTask
local LTask_NeedSupportSurvive = class.class 'LTask_NeedSupportSurvive' : extends 'LTask' {
--[[public]]
    ctor = function()end,
    
}
function LTask_NeedSupportSurvive:ctor(NodeDispName)
    class.LTask.ctor(self, NodeDispName)
end

function LTask_NeedSupportSurvive:OnInit()
    class.LTask.OnInit(self)

    
end

function LTask_NeedSupportSurvive:OnUpdate(DeltaTime)
    self:DoTerminate(true)
end