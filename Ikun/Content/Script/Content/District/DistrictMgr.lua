
---
---@brief   一个星球的行政区划管理器
---@author  zys
---@data    Sat Dec 21 2024 00:51:53 GMT+0800 (中国标准时间)
---@desc    行政区划管理器包含此星球所有国家(最大基本单位)
---

require("Content/District/Kingdom")

local SettlementType = require('Content/District/Settlements/SettlemengType')

---@class KingdomConfig
---@field KingdomCfgId number 国家配置id
---@field KingdomName string 国家名字
---@field KingdomDesc string 国家描述

---@class SettlementConfig
---@field SettlementId number
---@field SettlementName string
---@field SettlementType SettlementType
---@field BelongKingdomId number

---@class DistrictMgr
---@field OwnerStar StarClass 此星球
---@field tbKingdom Kingdom[] 此星球上的所有国家
---@field _tbSettlementRef table<number, SettlementBaseClass> 此星球上所有聚集地
local DistrictMgr = class.class"DistrictMgr" {
--[[public]]
    ctor = function() end,
    TickDistrictMgr = function(DeltaTime)end,
    FindKingdomByInstId = function(KingdomInstId)end,
    FindOrCreateSettlement = function()end,
    InitAllKingdom = function()end,
    OwnerStar = nil,
--[[private]]
    InitAllSettlement = function()end,
    tbKingdom = nil,
    _tbSettlementRef = nil,
}

---@override 初始化所有国家
---@param OwnerStar StarClass
function DistrictMgr:ctor(OwnerStar)
    self.OwnerStar = OwnerStar
    self.tbKingdom = {}
    self._tbSettlementRef = {}
    self:InitAllKingdom()
    self:InitAllSettlement()
end

---@public Tick国家
function DistrictMgr:TickDistrictMgr(DeltaTime)
    for _, kingdom in ipairs(self.tbKingdom) do
        kingdom:TickKingdom(DeltaTime)
    end
end

---@public 通过国家的实例Id找到国家
---@param KingdomInstId number
---@return Kingdom?
function DistrictMgr:FindKingdomByInstId(KingdomInstId)
    for _, kingdom in ipairs(self.tbKingdom) do
        if kingdom.KingdomInstId == KingdomInstId then
            return kingdom
        end
    end
    log.error('DistrictMgr:FindKingdomByInstId', '没有找到此国家, instance id:', KingdomInstId)
end

---@public 通过国家的配置Id找到国家
---@param KingdomCfgId number
---@return Kingdom?
function DistrictMgr:FindKingdomByCfgId(KingdomCfgId)
    for _, kingdom in ipairs(self.tbKingdom) do
        if kingdom.KingdomConfig.KingdomConfigId == KingdomCfgId then
            return kingdom
        end
    end
    log.error('DistrictMgr:FindKingdomByCfgId', '没有找到此国家, config id:', KingdomCfgId)
end

---@public [Init] 初始化此行星所有国家
function DistrictMgr:InitAllKingdom()
    local kingdomCfg = ConfigMgr:GetConfig('Kingdom') ---@type KingdomConfig[]
    for id, kingdom in pairs(kingdomCfg) do
        local instId = self.OwnerStar.StarId * 100 + id
        local kingdomInst = class.new "Kingdom" (instId, kingdom)
        table.insert(self.tbKingdom, kingdomInst)
    end
end

---@public [Init] 初始化所有人类聚集地
function DistrictMgr:InitAllSettlement()
    local settlementCfg = ConfigMgr:GetConfig('Settlement') ---@type SettlementConfig[]
    for id, settlement in pairs(settlementCfg) do
        local settlementInst = self:FindOrCreateSettlement(id)
        if not settlementInst then
            goto continue
        end
        local kingdom = self:FindKingdomByCfgId(settlement.BelongKingdomId)
        if not kingdom then
            log.error('DistrictMgr:InitAllSettlement()', '发现未定义的BelongKingdom',
                settlement.SettlementName, settlement.BelongKingdomId)
            goto continue
        end
        kingdom:AddSettlement(settlementInst)
        ::continue::
    end
end

---@public 通过Id获取聚集地
---@return SettlementBaseClass
function DistrictMgr:FindOrCreateSettlement(SettlementId)
    local allSettlementConfig = ConfigMgr:GetConfig('Settlement')
    local settlementConfig = allSettlementConfig[SettlementId] ---@type SettlementConfig
    if not settlementConfig then
        return log.error('DistrictMgr:FindSettlement()', '无效的SettlementId', SettlementId)
    end
    if self._tbSettlementRef[SettlementId] then
        return self._tbSettlementRef[SettlementId]
    end
    local settlement = nil
    if settlementConfig.SettlementType == SettlementType.City then
        settlement = class.new "CityClass" (settlementConfig.SettlementName, SettlementId) ---@type CityClass
    elseif settlementConfig.SettlementType == SettlementType.Village then
        settlement = class.new "VillageClass" (settlementConfig.SettlementName, SettlementId) ---@type VillageClass
    end
    self._tbSettlementRef[SettlementId] = settlement
    return settlement
end

return DistrictMgr