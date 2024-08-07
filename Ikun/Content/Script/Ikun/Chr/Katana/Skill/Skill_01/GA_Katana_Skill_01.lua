--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class GA_Katana_Skill_01
local GA_Katana_Skill_01 = UnLua.Class('Ikun.Blueprint.GAS.GA.BP_IkunGA')

---@private [Override]
function GA_Katana_Skill_01:OnActivateAbility()
    self.Overridden.OnActivateAbility(self)

    if not self.MontageToPlay then
        log.error('katana skill 01', 'failed to find montage')
        self:GAFail()
        return
    end

    self.OwnerChr = self:GetAvatarActorFromActorInfo()

    ---@type UATPlayMtgAndWaitEvent
    local AT = UE.UATPlayMtgAndWaitEvent.PlayMtgAndWaitEvent(self, 'task name', self.MontageToPlay, UE.UGameplayTagContainer,  1.0 , '', false, 1.0)
    AT.OnBlendOut:Add(self, self.OnCompleted)
    AT.OnCompleted:Add(self, self.OnCompleted)
    AT.OnInterrupted:Add(self, self.OnCancelled)
    AT.OnCancelled:Add(self, self.OnCancelled)
    AT.EventReceived:Add(self, self.EventReceived)
    AT:ReadyForActivation()

    local tag = UE.UIkunFuncLib.RequestGameplayTag("Input.MouseLeft.Down")
    local Wait = UE.UAbilityTask_WaitGameplayEvent.WaitGameplayEvent(self, tag, nil, false, true)
    -- self:RefTask(Wait)
    Wait.EventReceived:Add(self, self.InputMouseLeftDown)
    Wait:ReadyForActivation()
end

---@private [Override]
function GA_Katana_Skill_01:OnEndAbility(WasCancelled)
    self.Overridden.OnEndAbility(self, WasCancelled)
end

function GA_Katana_Skill_01:OnCompleted(EventTag, EventData)
    self:GASuccess()
end

function GA_Katana_Skill_01:OnCancelled(EventTag, EventData)
    self:GAFail()
end

function GA_Katana_Skill_01:EventReceived(EventTag, EventData)
    self:GASuccess()
end

function GA_Katana_Skill_01:InputMouseLeftDown(payload)
    
end

return GA_Katana_Skill_01