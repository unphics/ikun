
---
---@brief   游戏入口玩家控制器
---@author  zys
---@data    Fri Nov 07 2025 23:06:24 GMT+0800 (中国标准时间)
---

---@class BP_EntryPC: BP_PC_Base
local BP_EntryPC = UnLua.Class('Ikun/Blueprint/PC/BP_PC_Base')

function BP_EntryPC:ReceiveBeginPlay()
    self.bShowMouseCursor = true
end

return BP_EntryPC