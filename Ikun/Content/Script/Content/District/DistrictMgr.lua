
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

---@class DistrictMgr: MdBase
---@field OwnerStar Star 此星球
---@field tbKingdom Kingdom[] 此星球上的所有国家
local DistrictMgr = class.class"DistrictMgr" : extends "MdBase" {
--[[public]]
    ctor = function() end,
    Tick = function(DeltaTime)end,
    FindKingdomByInstId = function(KingdomInstId)end,
    OwnerStar = nil,
--[[private]]
    InitAllKingdom = function()end,
    InitAllSettlement = function()end,
    CreateSettlementByConfig = function(SettlementConfig)end,
    tbKingdom = nil,
}

---@override 初始化所有国家
function DistrictMgr:ctor(Star)
    self.OwnerStar = Star
    self.tbKingdom = {}
    self:InitAllKingdom()
    self:InitAllSettlement()
end

---@override Tick国家
function DistrictMgr:Tick(DeltaTime)
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
---@todo 找到多个
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

---@private 初始化此行星所有国家
function DistrictMgr:InitAllKingdom()
    local kingdomCfg = MdMgr.ConfigMgr:GetConfig('Kingdom') ---@type KingdomConfig[]
    for id, kingdom in pairs(kingdomCfg) do
        local instId = self.OwnerStar.StarId * 100 + id
        local kingdomInst = class.new "Kingdom" (instId, kingdom)
        table.insert(self.tbKingdom, kingdomInst)
    end
end

---@public 初始化所有人类聚集地
function DistrictMgr:InitAllSettlement()
    local settlementCfg = MdMgr.ConfigMgr:GetConfig('Settlement') ---@type SettlementConfig[]
    for _, settlement in pairs(settlementCfg) do
        local settlementInst = self:CreateSettlementByConfig(settlement)
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

---@private 通过配置创建村庄/城市
---@param SettlementConfig SettlementConfig
---@return SettlementBaseClass?
function DistrictMgr:CreateSettlementByConfig(SettlementConfig)
    if SettlementConfig.SettlementType == SettlementType.City then
        return class.new "CityClass" (SettlementConfig.SettlementName)
    elseif SettlementConfig.SettlementType == SettlementType.Village then
        return class.new "VillageClass" (SettlementConfig.SettlementName)
    else
        log.error('[DistrictMgr]:CreateSettlementByConfig Undefined SettlementType')
    end
    return nil
end