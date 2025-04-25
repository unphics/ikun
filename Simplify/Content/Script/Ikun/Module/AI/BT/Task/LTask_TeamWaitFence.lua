
---
---@brief 一起等待所有寻路抵达
---@author zys
---@data Fri Apr 25 2025 20:53:57 GMT+0800 (中国标准时间)
---

---@class LTask_TeamWaitFence : LTask
local LTask_TeamWaitFence = class.class 'LTask_TeamWaitFence' : extends 'LTask' {
    OnInit = function()end,
}
function LTask_TeamWaitFence:OnInit()
    class.LTask.OnInit(self)
    self.AllArrived = false
    self.Chr:GetRole().Team.TeamFence:RegisterTogether(function()
        self.AllArrived = true
    end)
end
function LTask_TeamWaitFence:OnUpdate()
    if self.AllArrived then
        self:DoTerminate(true)
    end
end