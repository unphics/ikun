
---
---@brief   游戏主界面
---@author  zys
---@data    Sun Nov 02 2025 14:31:25 GMT+0800 (中国标准时间)
---@todo    改名为Entry
---

---@class UI_Entry: UI_Entry_C
local UI_Entry = UnLua.Class()

---@override
function UI_Entry:Construct()
    self.UP_CreateSession.BtnSelect.OnClicked:Add(self, self._OnBtnCreateSessionWndClicked)
    self.UP_FindSession.BtnSelect.OnClicked:Add(self, self._OnBtnFindSessionWndClicked)
    self.BtnCreateSession.OnClicked:Add(self, self._OnBtnCreateSessionClicked)
    self.BtnFindSession.OnClicked:Add(self, self._OnBtnFindSessionClicked)
    self.BtnBack.OnClicked:Add(self, self._OnBtnBackClicked)
    self.UP_CreateSession.TxtDesc:SetText('创建会话')
    self.UP_FindSession.TxtDesc:SetText('查找会话')
end

---@override
function UI_Entry:Destroy()
    self.UP_CreateSession.BtnSelect.OnClicked:Clear()
    self.UP_FindSession.BtnSelect.OnClicked:Clear()
    self.BtnCreateSession.OnClicked:Clear()
    self.BtnFindSession.OnClicked:Clear()
    self.BtnBack.OnClicked:Clear()
end

---@override
function UI_Entry:OnShow()
    self.CvsCtrlWindow:SetVisibility(UE.ESlateVisibility.Hidden)
end

---@private
function UI_Entry:_OnBtnCreateSessionWndClicked()
    self.CvsCtrlWindow:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CvsCreateSession:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CvsFindSession:SetVisibility(UE.ESlateVisibility.Hidden)
end

---@private
function UI_Entry:_OnBtnFindSessionWndClicked()
    self.CvsCtrlWindow:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CvsCreateSession:SetVisibility(UE.ESlateVisibility.Hidden)
    self.CvsFindSession:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

---@private
function UI_Entry:_OnBtnBackClicked()
    self.CvsCtrlWindow:SetVisibility(UE.ESlateVisibility.Hidden)
end

---@private
function UI_Entry:_OnBtnCreateSessionClicked()
    local pc = self:GetOwningPlayer()
    local bLan = self.CheckLan:IsChecked()
    local count = tonumber(self.EditPersionCount:GetText()) or 10
    modules.GameSession:CreateSession(pc, count, bLan, function ()
        modules.GameLevelMgr:OpenGameLevel(pc)
    end)
end

---@private
function UI_Entry:_OnBtnFindSessionClicked()
    local pc = self:GetOwningPlayer()
    modules.GameSession:FindSession(pc, true, function (tbInSessionResult)
        ui_util.set_list_items(self.ListSession, tbInSessionResult)
    end)
end

return UI_Entry