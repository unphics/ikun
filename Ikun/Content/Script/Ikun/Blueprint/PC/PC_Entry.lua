
---
---@brief   游戏入口玩家控制器
---@author  zys
---@data    Fri Nov 07 2025 23:06:24 GMT+0800 (中国标准时间)
---

---@class PC_Entry: PC_Base
local PC_Entry = UnLua.Class('Ikun/Blueprint/PC/PC_Base')

---@override
function PC_Entry:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    
    if net_util.is_client(self)  then
        self.bShowMouseCursor = true
    end
end

return PC_Entry