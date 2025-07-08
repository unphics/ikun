
---
---@brief   Team管理器, 除了统一Tick外还没想好干点啥
---@author  zys
---@data    Sun Jul 06 2025 18:01:55 GMT+0800 (中国标准时间)
---

---@class TeamMgr: MdBase
---@field tbAllTeam TeamClass[]
local TeamMgr = class.class 'TeamMgr' : extends 'MdBase' {
--[[public]]
    ctor = function()end,
    Init = function()end,
    Tick = function()end,
--[[private]]
    tbAllTeam = nil,
}

---@override
function TeamMgr:ctor()
    
end

---@override
function TeamMgr:Init()
    self.tbAllTeam = {}
end

---@override
function TeamMgr:Tick(DeltaTime)
    for _, team in ipairs(self.tbAllTeam) do
        if team:IsTeamLive() then
            team:Tick(DeltaTime)
        end
    end
end

---@public
---@return TeamClass
function TeamMgr:CreateNewTeam()
    local id = #self.tbAllTeam
    local newTeam = class.new 'TeamClass' () ---@type TeamClass
    table.insert(self.tbAllTeam, newTeam)
    newTeam.TeamInfo:TeamInfoInitOnCreate(id)
    return newTeam
end

return TeamMgr