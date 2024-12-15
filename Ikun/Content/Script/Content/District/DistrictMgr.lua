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

---@class DistrictMgr: MdBase
---@field StarName string 行星的名字
---@field tbKingdom table 此行星所有国家
local DistrictMgr = class.class"DistrictMgr" : extends "MdBase" {
--[[public]]
    ctor = function(self, StarName) end,
    Init = function(self) end,
    GetKingdom = function(self, Id) end,
--[[private]]
    InitAllKingdom = function (self) end,
    tbKingdom = {},
    StarName = nil,
}
---@param StarName string
function DistrictMgr:ctor(StarName)
    self.StarName = StarName
    self:InitAllKingdom()
end
function DistrictMgr:GetKingdom(Id)
    return self.tbKingdom[Id]
end
-- 初始化此行星所有国家
function DistrictMgr:InitAllKingdom()
    for _, ele in ipairs(CfgKingdom) do
        table.insert(self.tbKingdom, class.new "Kingdom" (ele.Name))
    end
    for _, ele in ipairs(CfgSettlement) do
        local settlement
        if ele.Type == 1 then
            settlement = class.new "City" (ele.Name)
        elseif ele.Type == 2 then
            settlement = class.new "City" (ele.Name)
        end
        self.tbKingdom[ele.Kingdom]:AddSettlement(settlement)
    end
end