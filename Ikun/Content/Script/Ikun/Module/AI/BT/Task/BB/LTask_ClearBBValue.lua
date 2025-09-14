
---
---@brief 清理Blackboard中Key对应的值
---@author zys
---@data Mon May 19 2025 14:53:14 GMT+0800 (中国标准时间)
---

---@class LTask_ClearBBValue: LTask
local LTask_ClearBBValue = class.class 'LTask_ClearBBValue' : extends 'LTask' {
    ctor = function()end,
}
function LTask_ClearBBValue:ctor(NodeDispName, ...)
    class.LTask.ctor(self, NodeDispName)
    self.BBKeys = {...}
end
function LTask_ClearBBValue:OnInit()
    class.LTask.OnInit(self)

    for i, Key in ipairs(self.BBKeys) do
        self.Blackboard:SetBBValue(Key, nil)
    end
end
function LTask_ClearBBValue:OnUpdate(DeltaTime)
    self:DoTerminate(true)
end