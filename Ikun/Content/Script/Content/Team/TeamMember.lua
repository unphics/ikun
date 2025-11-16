---
---@brief 团队成员
---@author zys
---@data Wed Apr 23 2025 22:30:53 GMT+0800 (中国标准时间)
---

---@class TeamMemberClass
---@field OwnerTeam TeamClass
---@field TeamLeader RoleBaseClass
---@field dpMember duplex<number, RoleBaseClass>
local TeamMemberClass = class.class 'TeamMemberClass' {
    --[[public]]
    ctor = function() end,
    AddMember = function() end,
    RemoveMember = function()end,
    GetAllMember = function() end,
    ElectLeader = function() end,
    GetLeader = function() end,
    PrintMember = function() end,
    GetAllMember_PosCount = function()end,
    CalcMaxCountPerPos = function()end,
    --[[private]]
    tbMember = nil,
    OwnerTeam = nil,
    TeamLeader = nil,
}
function TeamMemberClass:ctor(Team)
    self.OwnerTeam = Team
    self.dpMember = duplex.create()
end
---@public 添加成员
function TeamMemberClass:AddMember(Role)
    self.dpMember:dinsert(Role:GetRoleId(), Role)
end
---@public 移除成员
function TeamMemberClass:RemoveMember(InstId)
    if not self.dpMember:dremove(InstId) then
        log.error('TeamMemberClass:RemoveMember() 不存在的RoleInstId')
    end
    if self.dpMember:dlength() == 0 then
        self.OwnerTeam.TeamInfo:TeamDestory()
    end
end
---@public 获取所有成员
function TeamMemberClass:GetAllMember()
    local allMemeber = {}
    for _, id, role in self.dpMember:diter() do
        if rolelib.is_live_role(role) then
            table.insert(allMemeber, role)
        end
    end
    return allMemeber
end
---@public 选举领导者
function TeamMemberClass:ElectLeader()
    local TeamLeader = nil
    for _, id, role in self.dpMember:diter() do
        TeamLeader = role
        break
    end
    self.TeamLeader = TeamLeader
end
function TeamMemberClass:GetLeader()
    if not self.TeamLeader or self.TeamLeader:IsRoleDead() then
        self:RemoveMember(self.TeamLeader:GetRoleId())
        self:ElectLeader()
    end
    return self.TeamLeader
end
---@public 打印成员类信息
function TeamMemberClass:PrintMember()
    local str = 'Team Leader =' .. self.TeamLeader.Avatar:PrintRoleInfo() .. ' :\n'
    for _, id, role in self.dpMember:diter() do
        str = str..'\t\t\t'..role.Avatar:PrintRoleInfo()..'\n'
    end
    return str
end
---@public [Pure] 根据战斗职业数量分表获取所有成员
---@return RoleBaseClass[], RoleBaseClass[]
function TeamMemberClass:GetAllMember_PosCount()
    local ArrSingle = {}
    local ArrMulti = {}
    for _, id, role in self.dpMember:diter() do
        local tbFPAssign = RoleMgr:GetRoleConfig(role:GetRoleCfgId()).FightPosAssign
        if not tbFPAssign or #tbFPAssign == 0 then
            log.error('TeamMemberClass:GetAllMember_PosCount() 发现不承担战场位置的角色', role:GetRoleCfgId())
        end
        if #tbFPAssign == 1 then
            table.insert(ArrSingle, role)
        else
            table.insert(ArrMulti, role)
        end
    end
    return ArrSingle, ArrMulti
end
---@public [Pure] 计算每个职业的最大人员数量
function TeamMemberClass:CalcMaxCountPerPos()
    local MaxCountPerPos = {}
    for _, id, role in self.dpMember:diter() do
        local tbFightPos = RoleMgr:GetRoleConfig(role:GetRoleCfgId()).FightPosAssign
        for _, pos in ipairs(tbFightPos) do
            if not MaxCountPerPos[pos] then
                MaxCountPerPos[pos] = 0
            end
            MaxCountPerPos[pos] = MaxCountPerPos[pos] + 1
        end
    end
    return MaxCountPerPos
end

return TeamMemberClass