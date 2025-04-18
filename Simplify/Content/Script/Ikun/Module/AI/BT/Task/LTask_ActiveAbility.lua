---
---@brief ActiveAbility
---@data Mon Jan 13 2025 15:53:06 GMT+0800 (中国标准时间)
---

---@class LTask_ActiveAbility: LTask
local LTask_ActiveAbility = class.class 'LTask_ActiveAbility' : extends 'LTask' {
    ctor = function()end,
    MaxWaitTime = nil,
    CurTime = nil,
}
function LTask_ActiveAbility:ctor(DisplayName, MaxWaitTime)
    class.LTask.ctor(self, DisplayName)

    self.MaxWaitTime = MaxWaitTime or 5
end
function LTask_ActiveAbility:OnInit()
    class.LTask.OnInit(self)

    self.CurTime = 0

    local SelectAbility = self.Blackboard:GetBBValue('SelectAbility')

    local Ability = UE.UAbilitySystemBlueprintLibrary.GetGameplayAbilityFromSpecHandle(self.Chr.ASC, SelectAbility.Handle) ---@type GA_IkunBase
    ---@todo
    -- if Ability then
    --     Ability:RegOnAbilityEnd(self, self.OnAbilityEnded)
    -- end

    local result = self.Chr.ASC:TryActivateAbility(SelectAbility.Handle, true)
    log.log('LTask_ActiveAbility:OnInit()', result)
end
function LTask_ActiveAbility:OnUpdate(DeltaTime)
    self.CurTime = self.CurTime + DeltaTime
    if self.CurTime > self.MaxWaitTime then
        self:DoTerminate(true)
    end
end
function LTask_ActiveAbility:OnTerminate() 
    log.log('LTask_ActiveAbility:OnTerminate')
end
function LTask_ActiveAbility:OnAbilityEnded(Ability)
    self.CurTime = self.MaxWaitTime - 1
end