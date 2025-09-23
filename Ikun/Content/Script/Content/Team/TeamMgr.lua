
---
---@brief   Team管理器, 除了统一Tick外还没想好干点啥
---@author  zys
---@data    Sun Jul 06 2025 18:01:55 GMT+0800 (中国标准时间)
---

---@class TeamMgr
---@field _tbAllTeam TeamClass[]
local TeamMgr = class.class 'TeamMgr'{
    ctor = function()end,
    CreateNewTeam = function()end,
    TickTeamMgr = function()end,
    _tbAllTeam = nil,
}

---@override
function TeamMgr:ctor()
    self._tbAllTeam = {}
end

---@public
function TeamMgr:TickTeamMgr(DeltaTime)
    for _, team in ipairs(self._tbAllTeam) do
        if team:IsTeamLive() then
            team:Tick(DeltaTime)
        end
    end
end

---@public
---@return TeamClass
function TeamMgr:CreateNewTeam()
    local id = #self._tbAllTeam
    local newTeam = class.new 'TeamClass' () ---@type TeamClass
    table.insert(self._tbAllTeam, newTeam)
    newTeam.TeamInfo:TeamInfoInitOnCreate(id)
    return newTeam
end

return TeamMgr