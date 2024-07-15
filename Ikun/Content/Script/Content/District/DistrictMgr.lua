--[[
    @brief 行政区划管理器
]]

require("Content/District/Kingdom")
require("Content/District/Zone")
require("Content/District/Settlements/Settlement")
require("Content/District/Settlements/City")
require("Content/District/Settlements/Village")

local CfgKingdom = require("Content/District/Config.Kingdom")
local CfgSettlement = require("Content/District/Config.Settlement")

class.class"DistrictMgr" : extends "MdBase" {
    tbKingdom = {},
    StarName = nil,
    ctor = function(self, StarName)
        self.StarName = StarName
    end,
    Init = function(self)
        self:InitAllKingdom()
    end,
    ---@private
    InitAllKingdom = function (self)
        for i, ele in ipairs(CfgKingdom) do
            table.insert(self.tbKingdom, class.new "Kingdom" (ele.Name))
        end
        for i, ele in ipairs(CfgSettlement) do
            local settlement
            if ele.Type == 1 then
                settlement = class.new "City" (ele.Name)
            elseif ele.Type == 2 then
                settlement = class.new "City" (ele.Name)
            end
            self.tbKingdom[ele.Kingdom]:AddSettlement(settlement)
        end
    end
}