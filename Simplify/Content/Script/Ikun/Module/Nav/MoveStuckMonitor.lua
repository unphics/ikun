---
---@brief 移动卡住监视器
---@author zys
---@data Sat Apr 05 2025 15:56:38 GMT+0800 (中国标准时间)
---@todo 处理更多阻挡情况
---

---@class MoveStuckMonitor
---@field MaxStuckTime number
---@field CurStuckTime number
---@field MoveStuckLoc FVector
local MoveStuckMonitor = class.class 'MoveStuckMonitor' {
    ctor = function()end,
    TickCheck = function()end,
}
function MoveStuckMonitor:ctor(MaxStuckTime, SelfChrAgentLoc)
    self.MaxStuckTime = MaxStuckTime
    self.MoveStuckLoc = SelfChrAgentLoc
    self.CurStuckTime = 0
end
---@public
---@param DeltaTime number
---@param SelfChrAgentLoc FVector
---@return boolean
function MoveStuckMonitor:TickCheck(DeltaTime, SelfChrAgentLoc)
    self.CurStuckTime = self.CurStuckTime + DeltaTime
    if UE.UKismetMathLibrary.EqualEqual_VectorVector(self.MoveStuckLoc, SelfChrAgentLoc, 10) then
        if self.CurStuckTime > self.MaxStuckTime then
            return true
        end
    else
        self.CurStuckTime = 0
        self.MoveStuckLoc = SelfChrAgentLoc
    end
    return false
end