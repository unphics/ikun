---
---@brief 大区
---

---@class Zone: MdBase
---@field tbSettlement table 所有城市/村庄
local Zone = class.class"Zone" : extends 'MdBase'{
--[public]
    ctor = function(Name) end,
--[[private]]
    Init = function() end,
    AddSettlement = function(Settlement) end,
    tbSettlement = {},
}
function Zone:ctor(Name)
end
function Zone:AddSettlement(Settlement)
    table.insert(self.tbSettlement, Settlement)
end