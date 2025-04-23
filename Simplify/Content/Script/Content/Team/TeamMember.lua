
---
---@brief 团队成员
---@author zys
---@data Wed Apr 23 2025 22:30:53 GMT+0800 (中国标准时间)
---

---@class TeamMemberClass
---@field OwnerTeam TeamClass
---@field tbMember RoleClass[]
---@field TeamLeader RoleClass
local TeamMemberClass = class.class 'TeamMemberClass' {
--[[public]]
    ctor = function()end,
    AddMember = function()end,
    GetAllMember = function()end,
    ElectLeader = function()end,
    GetLeader = function()end,
    PrintMember = function()end,
--[[private]]
    tbMember = nil,
    OwnerTeam = nil,
    TeamLeader = nil,
}
function TeamMemberClass:ctor(Team)
    self.OwnerTeam = Team
    self.tbMember = {}
end
---@public 添加成员
function TeamMemberClass:AddMember(Role)
    table.insert(self.tbMember, Role)
end
---@public 获取所有成员
function TeamMemberClass:GetAllMember()
    return table_util.shallow_copy(self.tbMember)
end
---@public 选举领导者
function TeamMemberClass:ElectLeader()
    local TeamLeader = self.tbMember[1]
    self.TeamLeader = TeamLeader
end
function TeamMemberClass:GetLeader()
    return self.TeamLeader
end
---@public 打印成员类信息
function TeamMemberClass:PrintMember()
    local str = 'Team Leader ='.. self.TeamLeader.Avatar:PrintRoleInfo() ..' :\n'
    for _, Role in ipairs(self.tbMember) do
        str = str .. '\t\t\t' .. Role.Avatar:PrintRoleInfo() .. '\n'
    end
    return str
end

return TeamMemberClass