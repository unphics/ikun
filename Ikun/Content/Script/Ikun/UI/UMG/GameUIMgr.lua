---
---@brief 游戏UI管理
---@author zys
---@data Sat Apr 05 2025 14:39:37 GMT+0800 (中国标准时间)
---

---@class GameUIMgr: GameUIMgr_C
---@field GameWorld UWorld
---@field tbUIWidget table<string, UUserWidget>
local GameUIMgr = UnLua.Class()

---@override
function GameUIMgr:Construct()
end

---@public
---@param Wolrd UWorld
function GameUIMgr:InitUIMgr(Wolrd)
    self.tbUIWidget = {}
    self.GameWorld = Wolrd
    ui_util.uimgr = self
    
    gameinit.registerinit(gameinit.ring.three, self, self._OpenDefaultUI)
end

---@public
function GameUIMgr:ShowUI(UIDef)
    log.info('[GameUIMgr:ShowUI] ', UIDef)
    local UI = self.tbUIWidget[UIDef]
    if UI then
        UI:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
        local UIClass = UE.UClass.Load(UIDef) 
        local PC = UE.UGameplayStatics.GetPlayerController(world_util.World, 0)
        UI = UE.UWidgetBlueprintLibrary.Create(world_util.World, UIClass, PC)
        local Slot = self.GameWindow:AddChild(UI) ---@type UCanvasPanelSlot
        UI:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        UI.bIsFocusable = true
        local Anchors = UE.FAnchors() ---@type FAnchors
        Anchors.Minimum = UE.FVector2D(0, 0)
        Anchors.Maximum = UE.FVector2D(1, 1)
        Slot:SetAnchors(Anchors)
        Slot:SetOffsets(UE.FMargin())
        self.tbUIWidget[UIDef] = UI
        UI.UIDef = UIDef
    end
    if UI.OnShow then
        UI:OnShow()
    end
    return UI
end

---@public
function GameUIMgr:HideUI(UIDef)
    log.info('[GameUIMgr:HideUI] ', UIDef)
    if not UIDef then
        return
    end
    local UI = self.tbUIWidget[UIDef]
    UI:SetVisibility(UE.ESlateVisibility.Hidden)
    if UI.OnHide then
        UI:OnHide()
    end
end

---@public
function GameUIMgr:DestoryUI(UIDef)
    log.info('[GameUIMgr:DestoryUI]', UIDef)
    local UI = self.tbUIWidget[UIDef]
    if UI then
        UI:RemoveFromParent()
        self.tbUIWidget[UIDef] = nil
    end
end

---@public
function GameUIMgr:GetUI(UIDef)
    if not UIDef then
        return
    end
    return self.tbUIWidget[UIDef]
end

---@public
function GameUIMgr:GetUIIfVisible(UIDef)
    local UI = self:GetUI(UIDef) ---@type UUserWidget
    if UI then
        local EVisi = UI:GetVisibility()
        if EVisi == UE.ESlateVisibility.Hidden or EVisi == UE.ESlateVisibility.Collapsed then
            return
        end
        return UI
    end
end

---@private 打开默认UI
function GameUIMgr:_OpenDefaultUI()
    local mapName = self.GameWorld:GetName()
    local defaultUIs = ConfigMgr:GetConfig('DefaultOpen')[mapName]
    if not defaultUIs then
        return log.error('找不到该地图的默认UI', mapName)
    end
    for i = 1, 10 do
        local name = defaultUIs['UI'..i]
        if name then
            self:ShowUI(ui_util.uidef[name])
        end
    end
end

return GameUIMgr