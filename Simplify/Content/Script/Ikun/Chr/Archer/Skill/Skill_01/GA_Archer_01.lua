local StarConfig = require("Content.Area.Config.StarConfig")

---
---@brief   弓箭手技能1
---@author  zys
---@data    Wed Aug 13 2025 20:39:21 GMT+0800 (中国标准时间)
---

---@class GA_Archer_01: GA_IkunBase
local GA_Archer_01 = UnLua.Class('Ikun/Blueprint/GAS/GA_IkunBase')

---@override
function GA_Archer_01:OnActivateAbility()
    self.Super.OnActivateAbility(self)
    log.dev('GA_Archer_01:OnActivateAbility()', net_util.print(self))

    ---@step montage play
    local at = UE.UATPlayMtgAndWaitEvent.PlayMtgAndWaitEvent(self, 'task name',
        self.MtgShoot, UE.FGameplayTagContainer(), 1, '', false, 1)
    at.OnBlendOut:Add(self, self.OnMtgCompleted)
    at.OnCompleted:Add(self, self.OnMtgCompleted)
    at.OnInterrupted:Add(self, self.OnMtgCancelled)
    at:ReadyForActivation()
    
    ---@step wait mouse left completed
    local tag = UE.UIkunFnLib.RequestGameplayTag('Input.MouseLeft.Completed')
    -- local stopTask= UE.UAbilityTask_WaitGameplayEvent.WaitGameplayEvent(self, tag, nil, true, true)
    -- stopTask.EventReceived:Add(self, self.OnMouseLeftCompleted)
    local stopTask = UE.UAbilityTask_WaitGameplayTagAdded.WaitGameplayTagAdd(self, tag, nil, true)
    stopTask.Added:Add(self, self.OnMouseLeftCompleted)
    stopTask:ReadyForActivation()

    ---@step camera move
    if net_util.is_server(self) then
        local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
        pc.CameraViewComp:S2C_NewCameraViewModel('Aim')
    end
end

---@override
function GA_Archer_01:K2_OnEndAbility(WasCancelled)
    self.Overridden.K2_OnEndAbility(self, WasCancelled)
end

---@private
function GA_Archer_01:OnMtgCompleted()
    self:GASuccess()
end

---@private
function GA_Archer_01:OnMtgCancelled()
    self:GAFail()
end

---@private [Server]
function GA_Archer_01:OnMouseLeftCompleted()
    log.dev('GA_Archer_01:OnMouseLeftCompleted()', net_util.print(self))
    ---@step montage jmp section
    self:MontageJumpToSection('Aim_End')
    
    ---@step camera move
    if net_util.is_server(self) then
        local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
        pc.CameraViewComp:S2C_NewCameraViewModel('Normal')
    end
end

return GA_Archer_01