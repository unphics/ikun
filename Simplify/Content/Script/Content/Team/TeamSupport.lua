
---
---@brief   团队支援
---@author  zys
---@data    Thu Jun 26 2025 23:14:41 GMT+0800 (中国标准时间)
---

---@class TeamSupportClass
---@field OwnerTeam TeamClass
---@field SupportPairs SupportInfo[]
local TeamSupportClass = class.class'TeamSupportClass' {
--[[public]]
    ctor = function()end,
    PublishSupportReq = function()end,
    BeginSupport = function()end,
    EndSupport = function()end,
    GetNoSupportCount = function()end,
--[[private]]
    SupportPairs = nil,
}
---@public
function TeamSupportClass:ctor(Team)
    self.OwnerTeam = Team
    self.SupportPairs = {}
end
---@public [Logic] 发布需要驰援的请求
function TeamSupportClass:PublishSupportReq(ReqRole)
    if ReqRole then
        ---@class SupportInfo
        ---@field ReqRole RoleClass
        ---@field Supporters RoleClass[]
        local SupportInfo = {
            ReqRole = ReqRole,
            Supporters = {}
        }
        table.insert(self.SupportPairs, SupportInfo)
    end
end
---@public [Logic] 不再需要支援
function TeamSupportClass:StopSupportReq(ReqRole)
    for i, info in ipairs(self.SupportPairs) do
        if info.ReqRole:GetRoleInstId() == ReqRole:GetRoleInstId() then
            table.remove(self.SupportPairs, i)
            break
        end
    end
end
---@public [Logic] 支援一下
---@param Role RoleClass
---@return RoleClass
function TeamSupportClass:BeginSupport(Role)
    local info = self.SupportPairs[1]
    for _, ele in ipairs(self.SupportPairs) do 
        if #ele.Supporters == 0 then
            info = ele
            break
        end
        if #ele.Supporters < #info.Supporters then
            info = ele
        end
    end
    table.insert(info.Supporters, Role)
    return info.ReqRole
end
---@public [] 结束支援
---@param RoleReq RoleClass 被支援者
---@param RoleRsp RoleClass 支援者
function TeamSupportClass:EndSupport(RoleReq, RoleRsp)
    for _, info in ipairs(self.SupportPairs) do
        if info.ReqRole:GetRoleInstId() == RoleReq:GetRoleInstId() then
            for i, role in ipairs(info.Supporters) do
                if role:GetRoleInstId() == RoleRsp() then
                    table.remove(info.Supporters, i)
                    break
                end
            end
        end
    end
end
---@public [Pure] 计算未被支援的数量
function TeamSupportClass:GetNoSupportCount()
    local count = 0
    for _, info in ipairs(self.SupportPairs) do
        if not (#info.Supporters > 0) then
            count = count + 1
        end
    end
    return count
end
