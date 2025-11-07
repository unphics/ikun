
---
---@brief   游戏入口界面的加入会话列表的Item
---@author  zys
---@data    Sat Nov 08 2025 00:00:28 GMT+0800 (中国标准时间)
---

---@class UP_FindSessionItem: UP_FindSessionItem_C
local M = UnLua.Class()

---@override
function M:Construct()
    self.BtnJoin.OnClicked:Add(self, self._OnBtnJoinClicked)
end

---@override
function M:Destruct()
    self.BtnJoin.OnClicked:Clear()
end

---@override
function M:OnListItemObjectSet(ListItemObject)
    self.BtnJoin:SetVisibility(UE.ESlateVisibility.Visible)
    local info = ListItemObject.Value ---@type SessionInfo
    self.TxtSessionName:SetText(info.SessionName)
    self.TxtPlayerCount:SetText('Player:'..info.CurPlayerNum..'/'..info.MaxPlayerNum)
    self.TxtSessionPing:SetText('Ping:'..info.PingMs)
    self.SessionResult = info.SessionResult
end

---@override
function M:BP_OnEntryReleased()
    self.SessionResult = nil
end

function M:_OnBtnJoinClicked()
    if self.SessionResult then
        self.BtnJoin:SetVisibility(UE.ESlateVisibility.Hidden)
        local pc = self:GetOwningPlayer()
        modules.GameSession:JoinSession(pc, self.SessionResult)
    end
end

return M
