
---
---@brief 团队行为的基类
---@author
---@data Thu Apr 24 2025 00:12:44 GMT+0800 (中国标准时间)
---

---@class TeamBehaviorBase: MdBase
---@field OwnerTeam TeamClass
local TeamBehaviorBase = class.class 'TeamBehaviorBase' : extends 'MdBase' {
--[[public]]
    ctor = function()end,
--[[private]]
    OwnerTeam = nil,
}
function TeamBehaviorBase:ctor(Team)
    self.OwnerTeam = Team
end
---@public
---@param EnemyTeam TeamClass
function TeamBehaviorBase:OnEncounterEnemy(EnemyTeam)
    
end

