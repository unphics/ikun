---
---@brief 团队成员
---@author zys
---@data Wed Apr 23 2025 22:30:53 GMT+0800 (中国标准时间)
---

local RoleConfig = require('Content/Role/Config/RoleConfig')

---@class TeamMemberClass
---@field OwnerTeam TeamClass
---@field tbMember RoleClass[]
---@field mapMemberId table<number, RoleClass>
---@field TeamLeader RoleClass
local TeamMemberClass = class.class 'TeamMemberClass' {
    --[[public]]
    ctor = function() end,
    AddMember = function() end,
    GetAllMember = function() end,
    ElectLeader = function() end,
    GetLeader = function() end,
    PrintMember = function() end,
    GetAllMember_CareerCount = function()end,
    --[[private]]
    tbMember = nil,
    mapMemberId = nil,
    OwnerTeam = nil,
    TeamLeader = nil,
}
function TeamMemberClass:ctor(Team)
    self.OwnerTeam = Team
    self.tbMember = {}
    self.mapMemberId = {}
end
---@public 添加成员
function TeamMemberClass:AddMember(Role)
    table.insert(self.tbMember, Role)
    self.mapMemberId[Role.RoleInstId] = Role
end
---@public 移除成员
function TeamMemberClass:RemoveMember(RoleInstId)
    self.mapMemberId[RoleInstId] = nil
    local Index = -1
    for i, Role in ipairs(self.tbMember) do
        if Role.RoleInstId == RoleInstId then
            Index = i
            break
        end
    end
    if Index > 0 then
        table.remove(self.tbMember, Index)
    else
        log.error('TeamMemberClass:RemoveMember() 不存在的RoleInstId')
    end
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
    local str = 'Team Leader =' .. self.TeamLeader.Avatar:PrintRoleInfo() .. ' :\n'
    for _, Role in ipairs(self.tbMember) do
        str = str .. '\t\t\t' .. Role.Avatar:PrintRoleInfo() .. '\n'
    end
    return str
end
---@public 根据战斗职业数量分表获取所有成员
---@return RoleClass[], RoleClass[]
function TeamMemberClass:GetAllMember_CareerCount()
    local ArrSingleCareer = {}
    local ArrMultiCarrer = {}
    for _, ele in ipairs(self.tbMember) do
        local Role = ele ---@type RoleClass
        local FightCareerAssign = RoleConfig[Role.RoleConfigId].FightCareerAssign
        if not FightCareerAssign or #FightCareerAssign == 0 then
            log.error('TeamMemberClass:GetAllMember_CareerCount() 发现不存在战斗职业的角色', Role.RoleConfigId)
        end
        if #FightCareerAssign == 1 then
            table.insert(ArrSingleCareer, Role)
        else
            table.insert(ArrMultiCarrer, Role)
        end
    end
    return ArrSingleCareer, ArrMultiCarrer
end
return TeamMemberClass