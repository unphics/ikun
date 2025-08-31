
---
---@brief   交互界面
---@author  zys
---@data    Sat Aug 23 2025 18:17:36 GMT+0800 (中国标准时间)
---

local EnhInput = require('Ikun/Module/Input/EnhInput')
local InputMgr = require("Ikun/Module/Input/InputMgr")

---@class UI_Chat: Chat_C
---@field CurInteractId number
---@field CurSelectIndex number
---@field CurSelectList table[]
---@field PowerInteract InputPower
local UI_Chat = UnLua.Class()

---@override
function UI_Chat:Construct()
    self.BtnTalkNext.OnClicked:Add(self, self.OnBtnTalkNextClicked)
end

---@override
function UI_Chat:Destruct()
    self.BtnTalkNext.OnClicked:Clear()
end

--function UI_Chat:Tick(MyGeometry, InDeltaTime)
--end

---@override
function UI_Chat:OnShow()
    -- local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    -- pc.InteractComp:C2S_ReqInteractBegin()
    self.PowerInteract = InputMgr.ObtainInputPower(self)
    InputMgr.RegisterInputAction(self.PowerInteract, EnhInput.IADef.IA_BlankSpace,
        EnhInput.TriggerEvent.Started, self.OnBtnTalkNextClicked)
    InputMgr.RegisterInputAction(self.PowerInteract, EnhInput.IADef.IA_Wheel,
        EnhInput.TriggerEvent.Started, self.OnWhellScroll)
    InputMgr.RegisterInputAction(self.PowerInteract, EnhInput.IADef.IA_Interact,
        EnhInput.TriggerEvent.Started, self.OnSelectInteract)
    InputMgr.RegisterInputAction(self.PowerInteract, EnhInput.IADef.IA_Tab,
        EnhInput.TriggerEvent.Started, self.OnQuitClicked)
    
    -- self:SetFocus()
    -- self:SetKeyboardFocus()

    self:ShowSelectPanel(false)
    self.TxtInteractName:SetText('')
    self.CvsTalk:SetVisibility(UE.ESlateVisibility.Hidden)
end

---@override
function UI_Chat:OnHide()
    -- local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    -- pc.InteractComp:C2S_ReqInteractEnd()
    InputMgr.UnregisterInputAction(self.PowerInteract)
    InputMgr.ReliquishInputPower(self.PowerInteract)
end

---@public
function UI_Chat:ShowTalkContent(TalkContent)
    if TalkContent then
        self.CvsTalk:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.TxtTalk:SetText(TalkContent)
    end
end

---@public [Data]
function UI_Chat:ShowSelectList(SelectList)
    self.CurSelectIndex = 1
    self.CurSelectList = SelectList
    self:UpdateSelectList()
end

---@private [Show]
function UI_Chat:UpdateSelectList()
    local list = {}
    for i, ele in ipairs(self.CurSelectList) do
        table.insert(list, {
            Index = i,
            Content = ele,
            bSelected = i == self.CurSelectIndex,
            OwnerUI = self,
            DoSelectIndex = self.DoSelectIndex,
            ScrollIndex = self.ScrollIndex
        })
    end
    ui_util.set_list_items(self.ListInteract, list)
    self:ShowSelectPanel(true)
end

---@private [Input]
function UI_Chat:OnQuitClicked()
    local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    pc.ChatComp:C2S_ReqEndChat()
end

---@private [Input] [ItemSelect]
function UI_Chat:DoSelectIndex(SelectIndex)
    if not self.CurSelectList then
        return
    end
    self:ShowSelectPanel(false)
    self.CurSelectList = nil
    local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    pc.ChatComp:C2S_DoSelectIndex(SelectIndex)
end

---@private [Op] [Select]
function UI_Chat:ScrollIndex(Index)
    self.CurSelectIndex = Index
    self:UpdateSelectList()
end

---@private [Op] [Input]
function UI_Chat:OnWhellScroll(ActionValue)
    if not self.CurSelectList then
        return
    end
    if ActionValue.X > 0.1 then
        local idx = self.CurSelectIndex
        idx = (idx - 1 < 1) and 1 or (idx - 1)
        self:ScrollIndex(idx)
    elseif ActionValue.X < -0.1 then
        local idx = self.CurSelectIndex
        idx = (idx + 1 > #self.CurSelectList) and idx or (idx + 1)
        self:ScrollIndex(idx)
    end
end

---@private [Show]
function UI_Chat:ShowSelectPanel(bShow)
    if bShow then
        self.CvsTri:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.CvsInteractPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
        self.CvsTri:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.CvsInteractPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
end

---@private [Input] 玩家按键下一句
function UI_Chat:OnBtnTalkNextClicked()
    if self.CurSelectList then
        return
    end
    local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    pc.ChatComp:C2S_TalkNext()
end

---@private [Input] 玩家按键选择当前选项
function UI_Chat:OnSelectInteract()
    self:DoSelectIndex(self.CurSelectIndex)
end

return UI_Chat