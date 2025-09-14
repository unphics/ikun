
---
---@brief   ActiveAbility
---@author  zys
---@data    Mon Jan 13 2025 15:53:06 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LTask_ActiveAbility: LTask
---@field ConstMaxWaitTime number
local LTask_ActiveAbility = class.class 'LTask_ActiveAbility' : extends 'LTask' {
    ctor = function()end,
    ConstMaxWaitTime = nil,
    CurTime = nil,
}

---@override
function LTask_ActiveAbility:ctor(NodeDispName, MaxWaitTime)
    class.LTask.ctor(self, NodeDispName)

    self.ConstMaxWaitTime = MaxWaitTime or 5
end

---@override
function LTask_ActiveAbility:OnInit()
    class.LTask.OnInit(self)

    self.CurTime = 0

    local SelectAbility = self.Blackboard:GetBBValue(BBKeyDef.SelectAbility)

    local Ability = UE.UAbilitySystemBlueprintLibrary.GetGameplayAbilityFromSpecHandle(self.Chr.ASC, SelectAbility.Handle) ---@type GA_IkunBase

    local result = self.Chr.ASC:TryActivateAbility(SelectAbility.Handle, true)
    -- log.debug('LTask_ActiveAbility:OnInit()', result)
end

---@override
function LTask_ActiveAbility:OnUpdate(DeltaTime)
    self.CurTime = self.CurTime + DeltaTime
    if self.CurTime > self.ConstMaxWaitTime then
        self:DoTerminate(true)
    end
end

---@override
function LTask_ActiveAbility:OnTerminate() 
    -- log.debug('LTask_ActiveAbility:OnTerminate')
end

return LTask_ActiveAbility