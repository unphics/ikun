
---
---@brief   道具
---@author  zys
---@data    Wed Aug 27 2025 00:32:22 GMT+0800 (中国标准时间)
---

---@class ItemBaseClass
local ItemBaseClass = class.class 'ItemBaseClass' {
--[[public]]
    ctor = function()end,
    ItemId = nil,
    ItemCfgId = nil,
--[[private]]
}

---@overide
function ItemBaseClass:ctor()    
end

return ItemBaseClass