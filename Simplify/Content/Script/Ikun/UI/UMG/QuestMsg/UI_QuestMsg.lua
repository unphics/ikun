
---
---@brief   任务消息显示
---@author  zys
---@data    Sat Aug 30 2025 12:37:03 GMT+0800 (中国标准时间)
---

---@class UI_QuestMsg: UI_QuestMsg_C
local M = UnLua.Class()

-- function M:Construct()
-- end

---@override
function M:OnShow()
    self:BindToAnimationFinished(self.PlayQuestMsg, {self, self.OnPlayQuestMsgFinished})
    self:PlayAnimation(self.PlayQuestMsg, 0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
end

---@override
function M:OnHide()
    self:UnbindAllFromAnimationFinished(self.PlayQuestMsg)
end

---@public
function M:SetQuestMsg(QuestName, QuestState)
    self.TxtQuestName:SetText(QuestName)
    self.TxtQuestState:SetText(QuestState)
end

function M:OnPlayQuestMsgFinished()
    ui_util.uimgr:HideUI(ui_util.uidef.UI_QuestMsg)
end

return M
