---
---@brief 国家
---@author zys
---@data Sat Dec 21 2024 00:51:53 GMT+0800 (中国标准时间)
---

-- 类注册
require("Content/District/Zone")
require("Content/District/Settlements/Settlement")
require("Content/District/Settlements/City")
require("Content/District/Settlements/Village")

---@class Kingdom : MdBase
---@field tbZone Zone[] 这个国家的所有大区/行省
---@field tbRole RoleClass[] 这个国家的所有角色
---@field tbRoleBornRecord number[] 这个国家出生(赋予籍贯)角色记录
---@field Name string
---@field KingdomInstId number
---@field KingdomConfig KingdomConfig
local Kingdom = class.class"Kingdom" : extends 'MdBase'{
--[[public]]
    ctor = function() end,
    Init = function() end,
    Tick = function() end,
    AddSettlement = function(Settlement) end,
    FindSettlementLua = function(Id) end,
    AddKingdomMember = function()end,
    CalcRoleKingdomFriendShip = function()end,
    KingdomInstId = nil,
    KingdomConfig = nil,
--[[private]]
    tbZone = nil,
    tbRole = nil,
    tbRoleBornRecord = nil,
    Name = nil,
}

---@param Config KingdomConfig
function Kingdom:ctor(Id, Config)
    self.tbRole = {}
    self.tbZone = {}
    self.tbRoleBornRecord = {}

    self.Name = Config.KingdomName
    self.KingdomConfig = Config
    self.KingdomInstId = Id

    local zone = class.new "Zone" ("default")
    table.insert(self.tbZone, zone)
end
function Kingdom:Tick(DeltaTime)
    for i, Role in ipairs(self.tbRole) do
        Role:Tick(DeltaTime)
    end
end
---@public 增加一个聚集地
function Kingdom:AddSettlement(Settlement)
    self.tbZone[1]:AddSettlement(Settlement)
end
---@public 根据聚集地Id查找实例
---@param SettlementId number
---@return Settlement
function Kingdom:FindSettlementLua(SettlementId)
    for _, zone in ipairs(self.tbZone) do
        for j, settlement in ipairs(zone.tbSettlement) do
            if j == SettlementId then
                return settlement
            end
        end
    end
end
---@public 增加一个角色成员
---@param Role RoleClass
function Kingdom:AddKingdomMember(Role)
    table.insert(self.tbRole, Role)
    ---@rule 内建规则: 对于没有实例Id的角色, 第一次挂靠的国家应赋予角色实例Id, 可以理解为出生籍贯
    if not Role:GetRoleInstId() then
        local InstId = self.KingdomInstId * 1000 + #self.tbRoleBornRecord
        table.insert(self.tbRoleBornRecord, Role:GetRoleDispName())
        Role.RoleInfo:InitRoleInstId(InstId)
        MdMgr.RoleMgr:NewRole(InstId, Role)
        log.info('zys AddKingdomMember', Role:GetRoleDispName(), self.Name, InstId)
    end
end
---@public 友谊度判断
---@version 0.1.0 简单判断国家相同则+5, 不同则-5
---@param Role RoleClass
function Kingdom:CalcRoleKingdomFriendShip(Role)
    if Role:GetBelongKingdom().KingdomInstId ~= self.KingdomInstId then
        return -5
    else
        return 5
    end
end