---
---@brief 游戏状态基类
---@author zys
---

---@class BP_GameStateBase: BP_GameStateBase_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

---@protected [ImplBP]
function M:ReceiveBeginPlay()
    world_util.GameWorld = self
    self:InitUIModule()

    -- 56.8ms
    -- async_util.delay(self, 2, function()
    --     log.dev('qqqqqqqqqqqqqq')
    --     local n = 10000
    --     local tb = {}
    --     for i = 1, n do
    --         table.insert(tb, self)
    --     end
    --     for _, gs in ipairs(tb) do
    --         obj_util.dispname(gs)
    --     end
    --     log.dev('eeeeeeeeeeeeee')
    -- end)
    
    -- 57.1
    -- async_util.delay(self, 2, function()
    --     log.dev('qqqqqqqqqqqqqq')
    --     local n = 10000
    --     local arr = UE.TArray(UE.AActor)
    --     for i = 1, n do
    --         arr:Add(self)
    --     end
    --     for i = 1, arr:Length() do
    --         obj_util.dispname(arr:Get(i))
    --     end
    --     log.dev('eeeeeeeeeeeeee')
    -- end)
end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

---@private [Client] [UIMgr]
function M:InitUIModule()
    ---@todo zys 服务端要不要界面
    -- if net_util.is_server(self) then
    --     return
    -- end
    local UIMgrClass = UE.UClass.Load('/Game/Ikun/UI/UMG/GameUIMgr.GameUIMgr_C')
    local UIMgr = UE.UWidgetBlueprintLibrary.Create(self, UIMgrClass, UE.UGameplayStatics.GetPlayerController(self, 0))
    if UIMgr then
        UIMgr:AddToViewport(0)
    end
end

return M