---
---@brief 行政区划管理器
---

require("Content/District/Kingdom")

local CfgKingdom = require("Content/District/Config/KingdomConfig")
local CfgSettlement = require("Content/District/Config/Settlement")
local SettlementType = require('Content/District/Settlements/SettlemengType')

---@class DistrictMgr: MdBase
---@field OwnerStar Star 行星
---@field tbKingdom Kingdom[] 此行星所有国家
local DistrictMgr = class.class"DistrictMgr" : extends "MdBase" {
--[[public]]
    ctor = function() end,
    Init = function() end,
    Tick = function()end,
    FindKingdomByInstId = function() end,
    OwnerStar = nil,
--[[private]]
    InitAllKingdom = function()end,
    CreateSettlementByConfig = function()end,
    tbKingdom = {},
}
function DistrictMgr:ctor(Star)
    self.OwnerStar = Star
    self:InitAllKingdom()
end
function DistrictMgr:Tick(DeltaTime)
    for i, Kingdom in ipairs(self.tbKingdom) do
        Kingdom:Tick(DeltaTime)
    end
end
---@param KingdomInstId number
function DistrictMgr:FindKingdomByInstId(KingdomInstId)
    for _, Kingdom in ipairs(self.tbKingdom) do
        if Kingdom.KingdomInstId == KingdomInstId then
            return Kingdom
        end
    end
    log.error('DistrictMgr: Failed to find kingdom by instance id:' .. tostring(KingdomInstId))
end
---@param KingdomCfgId number 
function DistrictMgr:FindKingdomByCfgId(KingdomCfgId)
    for _, Kingdom in ipairs(self.tbKingdom) do
        if Kingdom.KingdomConfig.KingdomConfigId == KingdomCfgId then
            return Kingdom
        end
    end
    log.error('DistrictMgr: Failed to find kingdom by config id: ' .. tostring(KingdomCfgId))
end
-- 初始化此行星所有国家
function DistrictMgr:InitAllKingdom()
    for idx, ele in ipairs(CfgKingdom) do
        local Id = self.OwnerStar.StarId * 100 + idx
        local Kingdom = class.new "Kingdom" (Id, ele)
        table.insert(self.tbKingdom, Kingdom)
    end
    for _, ele in ipairs(CfgSettlement) do
        local Config = ele ---@type SettlementConfig
        local Settlement = self:CreateSettlementByConfig(Config)
        local Kingdom = self.tbKingdom[Config.BelongKingdom]
        Kingdom:AddSettlement(Settlement)
    end
end
---@param Config SettlementConfig
function DistrictMgr:CreateSettlementByConfig(Config)
    if Config.SettlementType == SettlementType.City then
        return class.new "City" (Config.SettlementName)
    elseif Config.SettlementType == SettlementType.Village then
        return class.new "Village" (Config.SettlementName)
    else
        log.error('[DistrictMgr]:CreateSettlementByConfig Undefined SettlementType')
    end
    return nil
end