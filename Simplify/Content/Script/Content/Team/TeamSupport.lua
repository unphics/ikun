
---
---@brief   团队支援
---@author  zys
---@data    Thu Jun 26 2025 23:14:41 GMT+0800 (中国标准时间)
---

---@class TeamSupportClass
---@field OwnerTeam TeamClass
---@field dpSupportPair duplex<number, SupportInfo>
local TeamSupportClass = class.class'TeamSupportClass' {
--[[public]]
    ctor = function()end,
    PublishSupportReq = function()end,
    BeginSupport = function()end,
    EndSupport = function()end,
    GetNoSupportCount = function()end,
--[[private]]
    dpSupportPair = nil,
}
---@public
function TeamSupportClass:ctor(Team)
    self.OwnerTeam = Team
    self.dpSupportPair = duplex.create()
end
---@public [Logic] 发布需要驰援的请求; 被支援者调用
function TeamSupportClass:PublishSupportReq(ReqRole)
    if ReqRole then
        ---@class SupportInfo
        ---@field ReqRole RoleClass
        ---@field dpSupporters duplex<number, RoleClass>[]
        local SupportInfo = {
            ReqRole = ReqRole,
            dpSupporters = duplex.create()
        }
        self.dpSupportPair:dinsert(ReqRole:GetRoleInstId(), SupportInfo)
    end
end
---@public [Logic] 不再需要支援; 被支援者调用
function TeamSupportClass:StopSupportReq(ReqRole)
    self.dpSupportPair:dremove(ReqRole:GetRoleInstId())
end
---@public [Logic] 随便支援一个人; 支援者调用
---@param Role RoleClass
---@return RoleClass
function TeamSupportClass:BeginSupport(Role)
    local info = nil ---@type SupportInfo
    for _, k, ele in self.dpSupportPair:diter() do
        if ele.dpSupporters:dlength() == 0 then
            info = ele
            break
        end
        if not info then
            info = ele
        elseif ele.dpSupporters:dlength() < info.dpSupporters:dlength() then
            info = ele
        end
    end
    info.dpSupporters:dinsert(Role:GetRoleInstId(), Role)
    return info.ReqRole
end
---@public [Logic] 结束支援; 支援者调用
---@param RoleReq RoleClass 被支援者
---@param RoleRsp RoleClass 支援者
function TeamSupportClass:EndSupport(RoleReq, RoleRsp)
    local info = self.dpSupportPair:dfind(RoleReq:GetRoleInstId())
    if info then
        info.dpSupporters:dremove(RoleRsp:GetRoleInstId())
    end
end
---@public [Pure] 计算未被支援的数量
function TeamSupportClass:GetNoSupportCount()
    local count = 0
    for _, id, info in self.dpSupportPair:diter() do
        if info.dpSupporters:dlength() == 0 then
            count = count + 1
        end
    end
    return count
end
