
---
---@brief   房子
---@author  zys
---@data    Mon Sep 22 2025 22:16:52 GMT+0800 (中国标准时间)
---@desc    房子属于Location, 房子的门是Site, 房子Location属于Village, 房子Location属于地貌某某河流平原
---

---@class BP_House: BP_House_C
local BP_House = UnLua.Class()

---@public
---@return FVector
function BP_House:GetHousePosition()
    return self.HomeDoor:K2_GetComponentToWorld().Translation
end

return BP_House