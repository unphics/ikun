
---
---@brief   摊位
---@author  zys
---@data    Fri Oct 03 2025 12:46:36 GMT+0800 (中国标准时间)
---

---@class BP_Stall: BP_Stall_C
local BP_Stall = UnLua.Class()

---@override
function BP_Stall:ReceiveBeginPlay()
end

---@public 取得摊位的位置
---@return FVector
function BP_Stall:GetStallPosition()
    return self.Stall:K2_GetComponentToWorld().Translation
end

return BP_Stall