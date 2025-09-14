---
---@brief 游戏模式, 模块管理器在这里活动
---@author zys
---@data Fri May 30 2025 22:38:14 GMT+0800 (中国标准时间)
---

---@class BP_GameModeBase: BP_GameModeBase_C
local BP_GameModeBase = UnLua.Class()

-- function BP_GameModeBase:Initialize(Initializer)
-- end

function BP_GameModeBase:UserConstructionScript()
    log.info(log.key.ueinit..' BP_GameModeBase:UserConstructionScript()')
    local MdMgr = class.new"MdMgr"() ---@type MdMgr
    _G.MdMgr = MdMgr ---@type MdMgr
    _G.MdMgr:Init()
end

function BP_GameModeBase:ReceiveBeginPlay()
    log.info(log.key.ueinit..' BP_GameModeBase:ReceiveBeginPlay() svr:'..tostring(net_util.is_server(self)))
end

-- function BP_GameModeBase:ReceiveEndPlay()
-- end

function BP_GameModeBase:ReceiveTick(DeltaSeconds)
    _G.MdMgr:Tick(DeltaSeconds)
end

-- function BP_GameModeBase:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function BP_GameModeBase:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function BP_GameModeBase:ReceiveActorEndOverlap(OtherActor)
-- end

return BP_GameModeBase
