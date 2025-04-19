
---
---@brief 团队移动, 存储成员移动目标
---@author zys
---@data Sat Apr 19 2025 06:20:04 GMT+0800 (中国标准时间)
---

---@class TeamMoveClass
---@field OwnerTeam TeamClass
local TeamMoveClass = class.class 'TeamMoveClass' {
    ctor = function()end,
}
function TeamMoveClass:ctor(Team)
    self.OwnerTeam = Team
end
---@public
function TeamMoveClass:GetMoveTarget()
end