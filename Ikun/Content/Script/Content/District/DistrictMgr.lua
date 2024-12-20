---
---@brief 行政区划管理器
---

require("Content/District/Kingdom")
require("Content/District/Zone")
require("Content/District/Settlements/Settlement")
require("Content/District/Settlements/City")
require("Content/District/Settlements/Village")

local CfgKingdom = require("Content/District/Config/Kingdom")
local CfgSettlement = require("Content/District/Config/Settlement")
local SettlementType = require('Content/District/Settlements/SettlemengType')

---@class DistrictMgr: MdBase
---@field StarName string 行星的名字
---@field tbKingdom Kingdom[] 此行星所有国家
local DistrictMgr = class.class"DistrictMgr" : extends "MdBase" {
--[[public]]
    ctor = function(StarName) end,
    Init = function() end,
    Tick = function()end,
    GetKingdom = function(Id) end,
--[[private]]
    InitAllKingdom = function()end,
    CreateSettlementByConfig = function()end,
    tbKingdom = {},
    StarName = nil,
}
---@param StarName string
function DistrictMgr:ctor(StarName)
    self.StarName = StarName
    self:InitAllKingdom()
end
---@param KingdomId number
function DistrictMgr:GetKingdom(KingdomId)
    return self.tbKingdom[KingdomId]
end
-- 初始化此行星所有国家
function DistrictMgr:InitAllKingdom()
    for _, ele in ipairs(CfgKingdom) do
        table.insert(self.tbKingdom, class.new "Kingdom" (ele.Name))
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
function DistrictMgr:Tick(DeltaTime)
    for i, Kingdom in ipairs(self.tbKingdom) do
        Kingdom:Tick(DeltaTime)
    end
end