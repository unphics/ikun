
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
---@field public KingdomName string
---@field public KingdomInstId integer
---@field public KingdomConfig KingdomConfig
---@field private _tbZone ZoneClass[] 这个国家的所有大区/行省
---@field private _tbKingdomRoles table<integer, RoleBaseClass> 这个国家的所有角色
---@field private _tbRoleBornRecord number[] 这个国家出生(赋予籍贯)角色记录
local Kingdom = class.class"Kingdom" {}

---@override
---@param Config KingdomConfig
function Kingdom:ctor(Id, Config)
    self._tbKingdomRoles = {}
    self._tbZone = {}
    self._tbRoleBornRecord = {}

    self.KingdomName = Config.KingdomName
    self.KingdomConfig = Config
    self.KingdomInstId = Id

    ---@notice 现在默认所有聚集地都在大区1里, 等以后如果地域广大后重新处理大区划分问题
    local zone = class.new "ZoneClass" ("default")
    table.insert(self._tbZone, zone)
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
    self._tbZone[1]:AddSettlement(Settlement)
end

---@public [Pure] 根据聚集地Id查找实例
---@param SettlementId number
---@return SettlementBaseClass?
function Kingdom:FindSettlementLua(SettlementId)
    for _, zone in ipairs(self._tbZone) do
        for j, settlement in ipairs(zone.tbSettlement) do
            if j == SettlementId then
                return settlement
            end
        end
    end
end

---@public 负责生成角色在该国出生的唯一ID
---@param InRole RoleBaseClass
---@return integer
function Kingdom:GenRoleInstId(InRole)
    ---@rule 内建规则: 对于没有实例Id的角色, 第一次挂靠的国家应赋予角色实例Id, 可以理解为出生籍贯 -> 实例Id = 王国Id * 1000 + 出生序号
    local bornIndex = #self._tbRoleBornRecord + 1
    table.insert(self._tbRoleBornRecord, InRole:RoleName())
    return self.KingdomInstId * 1000 + bornIndex
end

---@public 给国家增加一个角色成员
---@param inRole RoleBaseClass
function Kingdom:AddKingdomMember(inRole)
    if self._tbKingdomRoles[inRole:GetRoleId()] then
        log.error('Kingdom:AddKingdomMember', '角色已存在于本国', inRole:RoleName(), self.KingdomName)
        return
    end

    self._tbKingdomRoles[inRole:GetRoleId()] = inRole
    log.info('AddKingdomMember', inRole:RoleName(), self.KingdomName, inRole:GetRoleId())
end

return Kingdom