--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class GA_Born: BP_IkunGA
local M = UnLua.Class('Ikun.Blueprint.GAS.GA.BP_IkunGA')

function M:OnActivateAbility()
    self.Overridden.OnActivateAbility(self)

    if not self.MontageToPlay then
        log.error('lich born', 'failed to find montage')
        self:GAFail()
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
    self:GASuccess()
end

function M:OnCancelled(EventTag, EventData)
    self:GAFail()
end

function M:EventReceived(EventTag, EventData)
    self:GASuccess()
end

return M