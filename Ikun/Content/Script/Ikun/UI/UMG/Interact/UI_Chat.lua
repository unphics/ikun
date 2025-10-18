
---
---@brief   对话界面
---@author  zys
---@data    Sat Aug 23 2025 18:17:36 GMT+0800 (中国标准时间)
---

local EnhInput = require('Ikun/Module/Input/EnhInput')
local InputMgr = require("Ikun/Module/Input/InputMgr")

---@class UI_Chat: Chat_C
---@field _CurSelectIndex number
---@field _CurSelectList table[]
---@field _InteractInputPower InputPower
local UI_Chat = UnLua.Class()

---@override
function UI_Chat:Construct()
    self.BtnTalkNext.OnClicked:Add(self, self._OnBtnTalkNextClicked)
end

---@override
function UI_Chat:Destruct()
    self.BtnTalkNext.OnClicked:Clear()
end

---@override
function UI_Chat:OnShow()
    log.info(log.key.chat, '对话界面打开')
    self._InteractInputPower = InputMgr.ObtainInputPower(self)
    InputMgr.RegisterInputAction(self._InteractInputPower, EnhInput.IADef.IA_BlankSpace, EnhInput.TriggerEvent.Started, self._OnBtnTalkNextClicked)
    InputMgr.RegisterInputAction(self._InteractInputPower, EnhInput.IADef.IA_Wheel, EnhInput.TriggerEvent.Started, self._OnWhellScroll)
    InputMgr.RegisterInputAction(self._InteractInputPower, EnhInput.IADef.IA_Interact, EnhInput.TriggerEvent.Started, self._OnSelectInteract)
    InputMgr.RegisterInputAction(self._InteractInputPower, EnhInput.IADef.IA_Tab, EnhInput.TriggerEvent.Started, self._OnQuitClicked)
    
    self:_ShowSelectPanel(false)
    self.TxtInteractName:SetText('')
    self.CvsTalk:SetVisibility(UE.ESlateVisibility.Hidden)
end

---@override
function UI_Chat:OnHide()
    log.info(log.key.chat, '对话界面关闭')
    InputMgr.UnregisterInputAction(self._InteractInputPower)
    InputMgr.ReliquishInputPower(self._InteractInputPower)
end

---@public 设置对话内容
function UI_Chat:ShowTalkContent(TalkContent)
    if TalkContent then
        log.info(log.key.chat, '对话界面显示对话内容', TalkContent)
        self.CvsTalk:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.TxtTalk:SetText(TalkContent)
    end
end

---@public [Data] 设置交互列表数据
function UI_Chat:SetSelectListData(SelectList)
    log.info(log.key.chat, '对话界面显示交互条目', #SelectList)
    self._CurSelectIndex = 1
    self._CurSelectList = SelectList
    self:_UpdateSelectList()
end

---@private [Input] 按Tab键按下后离开对话
function UI_Chat:_OnQuitClicked()
    log.info(log.key.chat, '对话界面按键关闭')
    local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    pc.ChatComp:C2S_ReqEndChat()
end

---@private [Input] [ItemSelect]
function UI_Chat:_DoSelectIndex(SelectIndex)
    if not self._CurSelectList then
        return
    end
    self:_ShowSelectPanel(false)
    self._CurSelectList = nil
    local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    pc.ChatComp:C2S_DoSelectIndex(SelectIndex)
end

---@private [Op] [Select] 选择该索引的条目
function UI_Chat:_ChatScrollIndex(Index)
    self._CurSelectIndex = Index
    self:_UpdateSelectList()
end

---@private [Op] [Input] 滚轮滑动后选择上一个和下一个条目
function UI_Chat:_OnWhellScroll(ActionValue)
    if not self._CurSelectList then
        return
    end
    if ActionValue.X > 0.1 then
        local idx = self._CurSelectIndex
        idx = (idx - 1 < 1) and 1 or (idx - 1)
        self:_ChatScrollIndex(idx)
    elseif ActionValue.X < -0.1 then
        local idx = self._CurSelectIndex
        idx = (idx + 1 > #self._CurSelectList) and idx or (idx + 1)
        self:_ChatScrollIndex(idx)
    end
end

---@private [Input] 玩家按空格后显示下一句
function UI_Chat:_OnBtnTalkNextClicked()
    if self._CurSelectList then
        return
    end
    log.info(log.key.chat, '对话界面按键后显示下一句')
    local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    pc.ChatComp:C2S_TalkNext()
end

---@private [Input] 玩家按F键后选择当前选项
function UI_Chat:_OnSelectInteract()
    log.info(log.key.chat, '对话界面按键选择当前条目')
    self:_DoSelectIndex(self._CurSelectIndex)
end

---@private [Show] 显示交互列表
function UI_Chat:_UpdateSelectList()
    local list = {}
    for i, ele in ipairs(self._CurSelectList) do
        table.insert(list, {
            Index = i,
            Content = ele,
            bSelected = i == self._CurSelectIndex,
            OwnerUI = self,
            FnDoSelectIndex = self._DoSelectIndex,
            FnChatScrollIndex = self._ChatScrollIndex
        })
    end
    ui_util.set_list_items(self.ListInteract, list)
    self:_ShowSelectPanel(true)
end

---@private [Show] 显示和隐藏右侧的选择面板
function UI_Chat:_ShowSelectPanel(bShow)
    if bShow then
        self.CvsTri:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.CvsInteractPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
        self.CvsTri:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.CvsInteractPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
end

return UI_Chat