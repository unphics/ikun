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
    if self.TeamLeader.Dead then
        self:RemoveMember(self.TeamLeader.RoleInstId)
        self:ElectLeader()
    end
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
---@public [Pure] 根据战斗职业数量分表获取所有成员
---@return RoleClass[], RoleClass[]
function TeamMemberClass:GetAllMember_PosCount()
    local ArrSingle = {}
    local ArrMulti = {}
    for _, ele in ipairs(self.tbMember) do
        local Role = ele ---@type RoleClass
        local tbFPAssign = RoleConfig[Role.RoleConfigId].FightPosAssign
        if not tbFPAssign or #tbFPAssign == 0 then
            log.error('TeamMemberClass:GetAllMember_CareerCount() 发现不承担战场位置的角色', Role.RoleConfigId)
        end
        if #tbFPAssign == 1 then
            table.insert(ArrSingle, Role)
        else
            table.insert(ArrMulti, Role)
        end
    end
    return ArrSingle, ArrMulti
end
---@public [Pure] 计算每个职业的最大人员数量
function TeamMemberClass:CalcMaxCountPerPos()
    local MaxCountPerPos = {}
    for _, ele in ipairs(self.tbMember) do
        local Role = ele ---@type RoleClass
        local tbFightPos = RoleConfig[Role.RoleConfigId].FightPosAssign
        for _, pos in ipairs(tbFightPos) do
            if not MaxCountPerPos[pos] then
                MaxCountPerPos[pos] = 0
            end
            MaxCountPerPos[pos] = MaxCountPerPos[pos] + 1
        end
    end
    return MaxCountPerPos
end
---@public
return TeamMemberClass