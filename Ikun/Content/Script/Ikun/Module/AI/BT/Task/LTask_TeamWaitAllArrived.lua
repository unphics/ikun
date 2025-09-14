
---
---@brief 等待所有队友抵达
---@author zys
---@data Fri Apr 25 2025 00:22:27 GMT+0800 (中国标准时间)
---

---@class LTask_TeamWaitAllArrived: LTask
---@field CurTime number
---@field StaticCheckInterval number 检测间隔
local LTask_TeamWaitAllArrived = class.class 'LTask_TeamWaitAllArrived' : extends 'LTask' {
    CurTime = nil
}
function LTask_TeamWaitAllArrived:OnInit()
    self.CurTime = 0
end

return LTask_TeamWaitAllArrived