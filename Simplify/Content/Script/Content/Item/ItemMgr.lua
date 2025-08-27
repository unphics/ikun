
---
---@brief   物件管理器
---@author zys
---@data   Thu Aug 28 2025 01:27:23 GMT+0800 (中国标准时间)
---

require('Content/Item/ItemBase')
require('Content/Item/Bag')

---@class ItemMgr:MdBase
local ItemMgr = class.class"ItemMgr": extends 'MdBase'{
    ctor = function()end,
    Init = function()end,
}

function ItemMgr:ctor()

end

return ItemMgr