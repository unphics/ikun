---
---@brief 游戏状态基类
---@author zys
---@data Fri May 30 2025 22:42:22 GMT+0800 (中国标准时间)
---

---@class BP_GameStateBase: BP_GameStateBase_C
local BP_GameStateBase = UnLua.Class()

-- function BP_GameStateBase:Initialize(Initializer)
-- end

-- function BP_GameStateBase:UserConstructionScript()
-- end

---@protected [ImplBP]
function BP_GameStateBase:ReceiveBeginPlay()
    world_util.World = self
    log.info(log.key.ueinit..' BP_GameStateBase:ReceiveBeginPlay() svr:'..tostring(net_util.is_server()))
    self:InitUIModule()

    -- 56.8ms
    -- async_util.delay(self, 2, function()
    --     print('qqqqqqqqqqqqqq')
    --     local n = 10000
    --     local tb = {}
    --     for i = 1, n do
    --         table.insert(tb, self)
    --     end
    --     for _, gs in ipairs(tb) do
    --         obj_util.dispname(gs)
    --     end
    --     print('eeeeeeeeeeeeee')
    -- end)
    
    -- 57.1
    -- async_util.delay(self, 2, function()
    --     print('qqqqqqqqqqqqqq')
    --     local n = 10000
    --     local arr = UE.TArray(UE.AActor)
    --     for i = 1, n do
    --         arr:Add(self)
    --     end
    --     for i = 1, arr:Length() do
    --         obj_util.dispname(arr:Get(i))
    --     end
    --     print('eeeeeeeeeeeeee')
    -- end)
end

-- function BP_GameStateBase:ReceiveEndPlay()
-- end

-- function BP_GameStateBase:ReceiveTick(DeltaSeconds)
-- end

-- function BP_GameStateBase:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function BP_GameStateBase:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function BP_GameStateBase:ReceiveActorEndOverlap(OtherActor)
-- end

---@private [Client] [UIMgr]
function BP_GameStateBase:InitUIModule()
    -- if net_util.is_server(self) then
    --     return
    -- end
    local UIMgrClass = UE.UClass.Load('/Game/Ikun/UI/UMG/GameUIMgr.GameUIMgr_C')
    local UIMgr = UE.UWidgetBlueprintLibrary.Create(self, UIMgrClass, UE.UGameplayStatics.GetPlayerController(self, 0))
    if UIMgr then
        UIMgr:AddToViewport(0)
    end
end

return BP_GameStateBase