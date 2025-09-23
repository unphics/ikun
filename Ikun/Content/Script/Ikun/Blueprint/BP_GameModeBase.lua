---
---@brief   游戏模式, 模块管理器在这里活动
---@author  zys
---@data    Fri May 30 2025 22:38:14 GMT+0800 (中国标准时间)
---

---@class BP_GameModeBase: BP_GameModeBase_C
local BP_GameModeBase = UnLua.Class()

---@override
function BP_GameModeBase:UserConstructionScript()
    log.info(log.key.ueinit..' BP_GameModeBase:UserConstructionScript()')
end

---@override
function BP_GameModeBase:ReceiveBeginPlay()
    log.info(log.key.ueinit..' BP_GameModeBase:ReceiveBeginPlay() svr:'..tostring(net_util.is_server(self)))
    async_util.delay(self, 0.5, function()
        gameinit.triggerinit(gameinit.ring.one)
    end)
    async_util.delay(self, 0.6, function()
        gameinit.triggerinit(gameinit.ring.two)
    end)
end

---@override
function BP_GameModeBase:ReceiveTick(DeltaSeconds)
    if net_util.is_server(self) then
        TimeMgr:TickTimeMgr(DeltaSeconds)
        TeamMgr:TickTeamMgr(DeltaSeconds)
        Cosmos:TickCosmos(DeltaSeconds)
    end
end

return BP_GameModeBase