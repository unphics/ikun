
---
---@brief 黑板Condition
---@author zys
---@data Sun May 18 2025 15:12:41 GMT+0800 (中国标准时间)
---

---@class LDecorator_BBCondition: LDecorator
---@field CondBBKeyName string
local LDecorator_BBCondition = class.class 'LDecorator_BBCondition' : extends 'LDecorator' {
--[[private]]
    CondBBKeyName = nil,
}
function LDecorator_BBCondition:ctor(DisplayName, CondBBKeyName)
    class.LDecorator.ctor(self, DisplayName)
    self.CondBBKeyName = CondBBKeyName
end
function LDecorator_BBCondition:Judge()
    if not self.Blackboard then
        return false
    end
    local Result = self.Blackboard:GetBBValue(self.CondBBKeyName)
    if not Result then
        return false
    end
    return true
end