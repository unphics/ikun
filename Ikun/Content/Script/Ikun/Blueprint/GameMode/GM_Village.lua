
---
---@brief   村庄地图的游戏模式
---@author  zys
---@data    Sat Nov 08 2025 00:12:13 GMT+0800 (中国标准时间)
---

---@class GM_Village: GM_Village_C
local GM_Village = UnLua.Class('Ikun/Blueprint/GameMode/GM_Base')

---@override
function GM_Village:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    
    log.info(log.key.ueinit..'GM_Village:ReceiveBeginPlay()', net_util.print(self))
end

---@override
function GM_Village:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds)
    TimeMgr:TickTimeMgr(DeltaSeconds)
    Cosmos:TickCosmos(DeltaSeconds)
end

function GM_Village:ReceiveEndPlay(EndReason)
end

return GM_Village