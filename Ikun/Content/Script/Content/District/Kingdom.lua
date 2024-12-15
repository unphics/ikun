---
---@brief 国家
---

---@class Kingdom : MdBase
local Kingdom = class.class"Kingdom" : extends 'MdBase'{
--[[public]]
    ctor = function(Name) end,
    Init = function() end,
    AddSettlement = function(Settlement) end,
    FindSettlementLua = function(Id) end,
--[[private]]
    tbZone = {},
}
function Kingdom:ctor(Name)
    local zone = class.new "Zone" ("default")
    table.insert(self.tbZone, zone)
end
function Kingdom:AddSettlement(Settlement)
    self.tbZone[1]:AddSettlement(Settlement)
end
function Kingdom:FindSettlementLua(Id)
    for i, zone in ipairs(self.tbZone) do
        for j, settlement in ipairs(zone.tbSettlement) do
            if j == Id then
                return settlement
            end
        end
    end
end