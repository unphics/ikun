
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

    async_util.delay(self:GetWorld(), 0.1, function()
        gameinit.triggerinit(gameinit.ring.one)
    end)
    async_util.delay(self:GetWorld(), 0.2, function()
        gameinit.triggerinit(gameinit.ring.two)
    end)
    async_util.delay(self:GetWorld(), 0.3, function()
        gameinit.triggerinit(gameinit.ring.three)
    end)
    async_util.delay(self:GetWorld(), 0.4, function()
        gameinit.triggerinit(gameinit.ring.four)
    end)
end

---@override
function GM_Village:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds)
    TimeMgr:TickTimeMgr(DeltaSeconds)
    TeamMgr:TickTeamMgr(DeltaSeconds)
    Cosmos:TickCosmos(DeltaSeconds)
end

return GM_Village