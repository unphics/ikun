
---
---@brief   UI开发中的业务层的常用工具方法
---@author  zys
---@data    Sun May 04 2025 14:22:37 GMT+0800 (中国标准时间)
---

---@class ui_util
---@field uidef UIDef
---@field uimgr GameUIMgr
local ui_util = {}

ui_util.uidef = require('Ikun/UI/UMG/GameUIDef')
ui_util.uimgr = nil
ui_util.mainhud = nil
-- ui_util.set_health_bar = function(num)
--     local game_state = UE.GetGameState()
-- end

ui_util.set_list_items = function(list_widget, array)
    local list_items = UE.TArray(UE.UObject)
    if type(array) == 'table' then
        for i = 1, #array do
            local obj = obj_util.new_uobj()
            obj.Value = array[i]
            list_items:Add(obj)
        end
        list_widget:BP_SetListItems(list_items)
    end
end

---@public
---@param World UWorld
ui_util.init_ui_module = function(World)
    if not obj_util.is_valid(World) then
        return
    end
    local UIMgrClass = UE.UClass.Load('/Game/Ikun/UI/UMG/GameUIMgr.GameUIMgr_C')
    local UIMgr = UE.UWidgetBlueprintLibrary.Create(World, UIMgrClass, UE.UGameplayStatics.GetPlayerController(World, 0))
    if UIMgr then
        UIMgr:AddToViewport(0)
        UIMgr:InitUIMgr(World)
    end
end

---@public
---@param UserWidget UUserWidget
ui_util.release_mouse = function(UserWidget)
    local PC = UE.UGameplayStatics.GetPlayerController(world_util.World, 0)
    UE.UWidgetBlueprintLibrary.SetInputMode_UIOnlyEx(PC, UserWidget, UE.EMouseLockMode.LockOnCapture, true)
end

---@public
ui_util.unrelease_mouse = function()
    local PC = UE.UGameplayStatics.GetPlayerController(world_util.World, 0)
    UE.UWidgetBlueprintLibrary.SetInputMode_GameOnly(PC, true)
end

---@public
---@param World UObject
ui_util.show_mouse = function(World)
    local pc = UE.UGameplayStatics.GetPlayerController(World, 0)
    pc.bShowMouseCursor = true
end

---@public
---@param World UObject
ui_util.hide_mouse = function(World)
    local pc = UE.UGameplayStatics.GetPlayerController(World, 0)
    pc.bShowMouseCursor = false
end

return ui_util

--[[

---@override
-- function M:Construct()
-- end

---@override
-- function M:Destruct()
-- end

---@override
-- function M:OnShow()
-- end

---@override
-- function M:OnHide()
-- end

---@override
--function M:Tick(MyGeometry, InDeltaTime)
--end

]]

--[[

---@override
-- function M:Construct()
-- end

---@override
-- function M:Destruct()
-- end

---@override
--function M:Tick(MyGeometry, InDeltaTime)
--end

---@override
--function M:OnListItemObjectSet(ListItemObject)
--end

---@override
--function M:BP_OnEntryReleased()
--end

]]