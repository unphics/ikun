
---
---@brief   游戏主界面
---@author  zys
---@data    Sun Nov 02 2025 14:31:25 GMT+0800 (中国标准时间)
---@todo    改名为Entry
---

---@class UI_Main: UI_Main_C
local UI_Main = UnLua.Class()

---@override
function UI_Main:Construct()
    self.UP_CreateSession.BtnSelect.OnClicked:Add(self, self._OnBtnCreateSessionWndClicked)
    self.UP_FindSession.BtnSelect.OnClicked:Add(self, self._OnBtnFindSessionWndClicked)
    self.BtnCreateSession.OnClicked:Add(self, self._OnBtnCreateSessionClicked)
    self.BtnFindSession.OnClicked:Add(self, self._OnBtnFindSessionClicked)
    self.BtnBack.OnClicked:Add(self, self._OnBtnBackClicked)
    self.UP_CreateSession.TxtDesc:SetText('创建会话')
    self.UP_FindSession.TxtDesc:SetText('查找会话')
end

---@override
function UI_Main:Destroy()
    self.UP_CreateSession.BtnSelect.OnClicked:Clear()
    self.UP_FindSession.BtnSelect.OnClicked:Clear()
    self.BtnCreateSession.OnClicked:Clear()
    self.BtnFindSession.OnClicked:Clear()
    self.BtnBack.OnClicked:Clear()
end

---@override
--function UI_Main:Tick(MyGeometry, InDeltaTime)
--end

function UI_Main:OnShow()
    log.dev('qqq')
    self.CvsCtrlWindow:SetVisibility(UE.ESlateVisibility.Hidden)
end

---@private
function UI_Main:_OnBtnCreateSessionWndClicked()
    self.CvsCtrlWindow:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CvsCreateSession:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CvsFindSession:SetVisibility(UE.ESlateVisibility.Hidden)
end

---@private
function UI_Main:_OnBtnFindSessionWndClicked()
    self.CvsCtrlWindow:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CvsCreateSession:SetVisibility(UE.ESlateVisibility.Hidden)
    self.CvsFindSession:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

---@private
function UI_Main:_OnBtnBackClicked()
    self.CvsCtrlWindow:SetVisibility(UE.ESlateVisibility.Hidden)
end

---@private
function UI_Main:_OnBtnCreateSessionClicked()
    local pc = self:GetOwningPlayer()
    local session = UE.UCreateSessionCallbackProxy.CreateSession(pc, pc, 10, true)
    session.OnSuccess:Add(self, function()
        UE.UGameplayStatics.OpenLevel(pc, 'VillageMap', true, "Listen")
    end)
    session.OnFailure:Add(self, function()
        log.error('failed to create session')
    end)
    session:Activate()
end

---@private
function UI_Main:_OnBtnFindSessionClicked()
    self:eee()
end

return UI_Main