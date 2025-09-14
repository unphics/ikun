---
---@brief LBT的黑板
---@author zys
---@data Tue Apr 15 2025 01:33:37 GMT+0800 (中国标准时间)
---

---@class BlackboardClass
---@field BlackboardData table
local BlackboardClass = class.class 'BlackboardClass' {
--[[public]]
    ctor = function()end,
--[[private]]
    BlackboardData = nil
}
function BlackboardClass:ctor()
    self:ResetBlackboard()
end
---@public
function BlackboardClass:ResetBlackboard()
    self.BlackboardData = {}   
end
function BlackboardClass:SetBBValue(Key, Value)
    self.BlackboardData[Key] = Value
end
function BlackboardClass:GetBBValue(Key)
    local Value = self.BlackboardData[Key]
    return Value
end

return BlackboardClass