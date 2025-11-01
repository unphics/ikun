
---
---@brief   国家
---@author  zys
---@data    Sat Dec 21 2024 00:51:53 GMT+0800 (中国标准时间)
---@desc    国家有很多大区行省, Kingdom包含所有挂靠在此Kingdom的Role, 负责执行他们的Tick(暂时), 凡是没有挂靠过其他国家的Role
---             则默认籍贯为第一次挂靠的Kingdom(此国家永久记录). 
---

-- 类注册
require("Content/District/Zone")
require("Content/District/Settlements/SettlementBase")
require("Content/District/Settlements/City")
require("Content/District/Settlements/Village")

---@class Kingdom
---@field tbZone ZoneClass[] 这个国家的所有大区/行省
---@field _tbKingdomRoles table<number, RoleClass> 这个国家的所有角色
---@field tbRoleBornRecord number[] 这个国家出生(赋予籍贯)角色记录
---@field KingdomName string
---@field KingdomInstId number
---@field KingdomConfig KingdomConfig
local Kingdom = class.class"Kingdom" {
--[[public]]
    ctor = function() end,
    Tick = function() end,
    AddSettlement = function(Settlement) end,
    FindSettlementLua = function(SettlementId) end,
    AddKingdomMember = function(inRole)end,
    CalcRoleKingdomFriendShip = function(rhsRole)end,
    KingdomInstId = nil,
    KingdomConfig = nil,
    KingdomName = nil,
--[[private]]
    tbZone = nil,
    _tbKingdomRoles = nil,
    tbRoleBornRecord = nil,
}

---@override
---@param Config KingdomConfig
function Kingdom:ctor(Id, Config)
    self._tbKingdomRoles = {}
    self.tbZone = {}
    self.tbRoleBornRecord = {}

    self.KingdomName = Config.KingdomName
    self.KingdomConfig = Config
    self.KingdomInstId = Id

    ---@notice 现在默认所有聚集地都在大区1里, 等以后如果地域广大后重新处理大区划分问题
    local zone = class.new "ZoneClass" ("default")
    table.insert(self.tbZone, zone)
end

---@override
function Kingdom:TickKingdom(DeltaTime)
    for id, role in pairs(self._tbKingdomRoles) do
        role:RoleTick(DeltaTime)
    end
end

---@public 增加一个聚集地
---@param Settlement SettlementBaseClass
function Kingdom:AddSettlement(Settlement)
    self.tbZone[1]:AddSettlement(Settlement)
end

---@public 根据聚集地Id查找实例
---@param SettlementId number
---@return SettlementBaseClass?
function Kingdom:FindSettlementLua(SettlementId)
    for _, zone in ipairs(self.tbZone) do
        for j, settlement in ipairs(zone.tbSettlement) do
            if j == SettlementId then
                return settlement
            end
        end
    end
end

---@public 给国家增加一个角色成员
---@todo 将添加角色接口变成挂靠角色或者角色加入国家
---@param inRole RoleClass
function Kingdom:AddKingdomMember(inRole)
    ---@rule 内建规则: 对于没有实例Id的角色, 第一次挂靠的国家应赋予角色实例Id, 可以理解为出生籍贯
    if not inRole:GetRoleInstId() then
        local InstId = self.KingdomInstId * 1000 + #self.tbRoleBornRecord
        table.insert(self.tbRoleBornRecord, inRole:RoleName())
        inRole.RoleInfo:InitRoleInstId(InstId)
        RoleMgr:NewRole(InstId, inRole)
    end
    self._tbKingdomRoles[inRole:GetRoleInstId()] = inRole
    log.info('zys AddKingdomMember', inRole:RoleName(), self.KingdomName, inRole:GetRoleInstId())
end

---@public 友谊度判断
---@version 0.1.0 简单判断国家相同则+5, 不同则-5
---@param rhsRole RoleClass
function Kingdom:CalcRoleKingdomFriendShip(rhsRole)
    if rhsRole:GetBelongKingdom().KingdomInstId ~= self.KingdomInstId then
        return -5
    else
        return 5
    end
end

return Kingdom