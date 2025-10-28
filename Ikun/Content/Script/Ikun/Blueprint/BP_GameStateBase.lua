---
---@brief   游戏状态基类
---@author  zys
---@data    Fri May 30 2025 22:42:22 GMT+0800 (中国标准时间)
---

---@class BP_GameStateBase: BP_GameStateBase_C
local BP_GameStateBase = UnLua.Class()

---@protected [ImplBP]
function BP_GameStateBase:ReceiveBeginPlay()
    world_util.World = self
    log.info(log.key.ueinit..' BP_GameStateBase:ReceiveBeginPlay() svr:'..tostring(net_util.is_server()))
    self:InitUIModule()
end

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