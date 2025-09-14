
---
---@brief 团队状态机
---@author zys
---@data Wed Apr 23 2025 23:30:59 GMT+0800 (中国标准时间)
---

---@class TeamStateClass
---@field OwnerTeam TeamClass
local TeamStateClass = class.class 'TeamStateClass' {
--[[public]]
    ctor = function()end,
}
function TeamStateClass:ctor(Team)
    self.OwnerTeam = Team    
end
function TeamStateClass:NextTeamState()
end

return TeamStateClass