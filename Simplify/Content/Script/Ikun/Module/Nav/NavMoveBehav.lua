
---
---@brief   移动行为
---@author  zys
---@data    Wed Jun 18 2025 00:02:19 GMT+0800 (中国标准时间)
---

---@class NavMoveBehav : MdBase
---@field Chr BP_ChrBase
---@field Role RoleClass
---@field MoveToInfo MoveToInfo
local NavMoveBehav = class.class 'NavMoveBehav' : extends 'MdBase' {
--[[public]]
    ctor = function()end,
    NewMoveTo = function()end,
--[[private]]
    Chr = nil,
    Role = nil,
}
---@override
---@param Chr BP_ChrBase|RoleClass
function NavMoveBehav:ctor(Chr)
    self.Chr = log.chr(Chr)
    self.Role = log.role(Chr)
end
---@class NavMoveBehavCallbackInfo
---@field OnNavMoveArrived function 抵达时
---@field OnNavMoveLostTarget function 失去目标时
---@field OnNavMoveCancelled function 取消时
---@field OnNavMoveStuck function 阻挡被时
---@public 移动到一个新地方
---@param Target BP_ChrBase|FVector
---@param CallbackInfo NavMoveBehavCallbackInfo
function NavMoveBehav:NewMoveTo(Target, CallbackInfo)
    ---@class MoveToInfo
    local Info = {
        MoveTarget = Target,
        TargetLoc = UE.FVector(),
        bArrived = false,
        bLostTarget = false,
        bCancelled = false,
        bStuck = false,
    }
    self.MoveToInfo = Info
end