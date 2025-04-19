
---
---@brief 取到团队寻路目标
---@author zys
---@data Sat Apr 19 2025 06:04:16 GMT+0800 (中国标准时间)
---

local TeamMoveType = require('Content/Team/TeamMoveType')

---@class LTask_TeamNavTarget : LTask
---@field ConstNearestDist number 查找点的最近限制
local LTask_TeamNavTarget = class.class'LTask_TeamNavTarget' : extends 'LTask' {
--[[public]]
    ctor = function()end,
    OnInit = function()end,
    OnUpdate = function()end,
--[[private]]
}
function LTask_TeamNavTarget:ctor(DispName, NearestDist, FarestDist, MaxIterCount)
    class.LTask.ctor(self, DispName)
    self.ConstNearestDist = NearestDist
    self.ConstFarestDist = FarestDist
    self.ConstMaxIterCount = MaxIterCount
    self.ResetLoc = nil
end
function LTask_TeamNavTarget:OnInit()
    class.LTask.OnInit(self)
    local Role = self.Chr:GetRole()
    Role.Team:GetRoleMoveTarget(Role, )
end
