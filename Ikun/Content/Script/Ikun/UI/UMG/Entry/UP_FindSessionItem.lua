--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

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
    local sessionResult = ListItemObject.Value ---@type FBlueprintSessionResult
    local svrName = UE.UFindSessionsCallbackProxy.GetServerName(sessionResult)
    self.TxtSessionName:SetText(svrName)
    local curPlayerNum = UE.UFindSessionsCallbackProxy.GetCurrentPlayers(sessionResult)
    local maxPlayerNum = UE.UFindSessionsCallbackProxy.GetMaxPlayers(sessionResult)
    self.TxtPlayerCount:SetText('Player:'..curPlayerNum..'/'..maxPlayerNum)
    local ping = UE.UFindSessionsCallbackProxy.GetPingInMs(sessionResult)
    self.TxtSessionPing:SetText('Ping:'..ping)
    self.SessionResult = sessionResult
end

---@override
function M:BP_OnEntryReleased()
    self.SessionResult = nil
end

function M:_OnBtnJoinClicked()
    if self.SessionResult then
        local pc = self:GetOwningPlayer()
        self.BtnJoin:SetVisibility(UE.ESlateVisibility.Hidden)
        local proxy = UE.UJoinSessionCallbackProxy.JoinSession(pc, pc, self.SessionResult)
        proxy.OnSuccess:Add(self, function()
            log.dev('succeed to join')
        end)
        proxy.OnFailure:Add(self, function()
            log.dev('failed to join')
        end)
        proxy:Activate()
    end
end

return M
