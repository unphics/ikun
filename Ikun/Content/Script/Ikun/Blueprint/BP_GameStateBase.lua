---
---@brief   游戏状态基类
---@author  zys
---@data    Fri May 30 2025 22:42:22 GMT+0800 (中国标准时间)
---

---@class BP_GameStateBase: BP_GameStateBase_C
local BP_GameStateBase = UnLua.Class()

---@override
function BP_GameStateBase:ReceiveBeginPlay()
    world_util.World = self
    log.info(log.key.ueinit, ' BP_GameStateBase:ReceiveBeginPlay()', net_util.print(self))
end

---@override
function BP_GameStateBase:ReceiveEndPlay()
end

return BP_GameStateBase