local worldutil = require("Util.World.WorldUtil")

class.class "UIMgr" {
    tbUIInst = {},
    LayerMgr = nil,
    ctor = function (self, LayerMgr)
        ui_util.uimgr = self
        self.LayerMgr = LayerMgr
        self:ShowDefaultUI()
    end,
    ---@public
    OpenUI = function (self, UIInfo)
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
    end,
    ---@public
    CloseUI = function (self, UIInfo)
        local Inst = self.tbUIInst[UIInfo.UIName]
        if Inst then
            Inst:RemoveFromParent()
            self.tbUIInst[UIInfo.UIName] = nil
            local PC = UE.UGameplayStatics.GetPlayerController(world_util.GameWorld, 0)
            UE.UWidgetBlueprintLibrary.SetInputMode_GameOnly(PC, true)
        end
    end,
    ---@public
    GetUIInst = function (self, UIInfo)
        local Inst = self.tbUIInst[UIInfo.UIName]
        return Inst
    end,
    ---@private
    ShowDefaultUI = function (self)
        for i, ui in pairs(ui_util.uidef.UIInfo) do
            if ui.DefaultOpen then
                self:OpenUI(ui)
            end
        end
    end,
}