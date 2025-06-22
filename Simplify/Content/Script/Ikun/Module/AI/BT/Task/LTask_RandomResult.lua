
---
---@brief   随机结果
---@author  zys
---@data    Sun Jun 22 2025 17:58:06 GMT+0800 (中国标准时间)
---

---@class LTask_RandomResult: LTask
---@field ConstSideValue number
local LTask_RandomResult = class.class'LTask_RandomResult' : extends 'LTask' {
    ctor = function()end,
    OnInit = function()end,
    OnUpdate = function()end,
    ConstSideValue = nil,
}
function LTask_RandomResult:ctor(TaskName, SideValue)
    class.LTask.ctor(self, TaskName)
    self.ConstSideValue = SideValue
end
function LTask_RandomResult:OnInit()
    class.LTask.OnInit(self)
end
function LTask_RandomResult:OnUpdate()
    if math.random() < self.ConstSideValue then
        self:DoTerminate(true)
    else
        self:DoTerminate(false)
    end
end