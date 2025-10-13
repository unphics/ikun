
---
---@brief   房子
---@author  zys
---@data    Mon Sep 22 2025 22:16:52 GMT+0800 (中国标准时间)
---

---@class BP_House: BP_House_C
local BP_House = UnLua.Class()

---@public
---@return FVector
function BP_House:GetHousePosition()
    return self.HomeDoor:K2_GetComponentToWorld().Translation
end

return BP_House