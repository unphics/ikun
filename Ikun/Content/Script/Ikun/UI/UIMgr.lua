---
---@brief UI管理器
---

---@class UIMgr
local UIMgr = class.class "UIMgr" {
--[[public]]
    ctor = function(LayerMgr)end,
    OpenUI = function(UIInfo)end,
    CloseUI = function(UIInfo)end,
    GetUIInst = function(UIInfo)end,
--[[private]]
    ShowDefaultUI = function()end,
    tbUIInst = {},
    LayerMgr = nil,
}
function UIMgr:ctor(LayerMgr)
    log.log('[UIMgr]:ctor')
    ui_util.uimgr = self
    self.LayerMgr = LayerMgr
    self:ShowDefaultUI()
end
---@param UIInfo UIInfo
function UIMgr:OpenUI(UIInfo)
    log.log('[UIMgr]:OpenUI ', UIInfo.UIName)
    local UIInst = nil
    if self.tbUIInst[UIInfo.UIName] then
        UIInst = self.tbUIInst[UIInfo.UIName]
        UIInst:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
        local UIClass = UE.UClass.Load(UIInfo.ClassPath)
        UIInst = UE.UWidgetBlueprintLibrary.Create(world_util.GameWorld, UIClass, UE.UGameplayStatics.GetPlayerController(world_util.GameWorld, 0))

        local Slot = self.LayerMgr[UIInfo.Layer]:AddChild(UIInst)
        
        UIInst:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        UIInst.IsFocusable = true
        local Anchors = UE.FAnchors()
        Anchors.Minimum = UE.FVector2D(0, 0)
        Anchors.Maximum = UE.FVector2D(1, 1)
        Slot:SetAnchors(Anchors)
        Slot:SetOffsets(UE.FMargin())
        local ZOrder = 0
        Slot:SetZOrder(ZOrder)

        self.tbUIInst[UIInfo.UIName] = UIInst
        local PC = UE.UGameplayStatics.GetPlayerController(world_util.GameWorld, 0)
        if UIInfo.ReleaseMouse then
            UE.UWidgetBlueprintLibrary.SetInputMode_UIOnlyEx(PC, UIInst, UE.EMouseLockMode.LockOnCapture, true)
        else
            UE.UWidgetBlueprintLibrary.SetInputMode_GameOnly(PC, true)
        end
    end
    return UIInst
end
---@param UIInfo UIInfo
function UIMgr:CloseUI(UIInfo)
    log.log('[UIMgr]:CloseUI ', UIInfo.UIName)
    local Inst = self.tbUIInst[UIInfo.UIName]
    if Inst then
        Inst:RemoveFromParent()
        self.tbUIInst[UIInfo.UIName] = nil
        local PC = UE.UGameplayStatics.GetPlayerController(world_util.GameWorld, 0)
        UE.UWidgetBlueprintLibrary.SetInputMode_GameOnly(PC, true)
    end
end
---@param UIInfo UIInfo
function UIMgr:GetUIInst(UIInfo)
    local Inst = self.tbUIInst[UIInfo.UIName]
    return Inst
end
function UIMgr:ShowDefaultUI()
    for _, ui in pairs(ui_util.uidef.UIInfo) do
        if ui.DefaultOpen then
            self:OpenUI(ui)
        end
    end
end