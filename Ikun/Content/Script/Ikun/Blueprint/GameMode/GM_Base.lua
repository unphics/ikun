
---
---@brief   游戏模式基类
---@author  zys
---@data    Fri May 30 2025 22:38:14 GMT+0800 (中国标准时间)
---

---@class GM_Base: GM_Base_C
local GM_Base = UnLua.Class()

---@override
function GM_Base:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)

    log.info(log.key.ueinit..'GM_Base:ReceiveBeginPlay()', net_util.print(self))
end

---@override
function GM_Base:ReceiveTick(DeltaSeconds)
end

return GM_Base