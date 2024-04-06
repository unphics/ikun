--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type GA_Born_C
local M = UnLua.Class()

function M:OnActivateAbility()
    self.Overridden.OnActivateAbility(self)

    if not self.MontageToPlay then
        log.error('lich born', 'failed to find montage')
        return
    end

    ---@type UATPlayMtgAndWaitEvent
    local AT = UE.UATPlayMtgAndWaitEvent.PlayMtgAndWaitEvent(self, 'task name', self.MontageToPlay, UE.UGameplayTagContainer,  1.0 , '', false, 1.0)
    AT.OnBlendOut:Add(self, self.OnCompleted)
    AT.OnCompleted:Add(self, self.OnCompleted)
    AT.OnInterrupted:Add(self, self.OnCancelled)
    AT.OnCancelled:Add(self, self.OnCancelled)
    AT.EventReceived:Add(self, self.EventReceived)
    -- ReadyForActivation()是在C++中激活AbilityTask的方法。蓝图具有K2Node_LatentGameplayTaskCall的能力，它会自动调用ReadyForActivation()
    AT:ReadyForActivation()
end

function M:OnEndAbility(WasCancelled)
    self.Overridden.OnEndAbility(self, WasCancelled)
end

function M:OnCompleted(EventTag, EventData)
    self.Result = true
    self:K2_EndAbility()
end

function M:OnCancelled(EventTag, EventData)
    self.Result = false
    self:K2_EndAbility()
end

function M:EventReceived(EventTag, EventData)
    self.Result = true
    self:K2_EndAbility()
end

return M