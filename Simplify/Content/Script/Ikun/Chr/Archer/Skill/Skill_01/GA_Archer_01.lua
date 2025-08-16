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

    ---@step check
    if gas_util.has_loose_tag(self.AvatarLua, 'Input.MouseLeft.Completed') then
        self:GAFail()
        return log.error('GA_Archer_01:OnActivateAbility()', '右键的Tag没Consume', net_util.print(self))
    end

    ---@step 播放蒙太奇动作
    local at = UE.UATPlayMtgAndWaitEvent.PlayMtgAndWaitEvent(self, 'task name',
        self.MtgShoot, UE.FGameplayTagContainer(), 1, '', false, 1)
    at.OnBlendOut:Add(self, self.OnMtgCompleted)
    at.OnCompleted:Add(self, self.OnMtgCompleted)
    at.OnInterrupted:Add(self, self.OnMtgCancelled)
    at:ReadyForActivation()
    
    ---@step 等待鼠标左键松开事件
    if net_util.is_server(self) then
        local tag = UE.UIkunFnLib.RequestGameplayTag('Input.MouseLeft.Completed')
        local stopTask= UE.UAbilityTask_WaitGameplayEvent.WaitGameplayEvent(self, tag, nil, true, true)
        stopTask.EventReceived:Add(self, self.OnMouseLeftCompleted)
        -- local stopTask = UE.UAbilityTask_WaitGameplayTagAdded.WaitGameplayTagAdd(self, tag, nil, true)
        -- stopTask.Added:Add(self, self.OnMouseLeftCompleted)
        stopTask:ReadyForActivation()
    end

    ---@step 相机切换到越肩视角
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

---@private
function GA_Archer_01:OnMouseLeftCompleted()
    self:S2C_OnMouseLeftCompleted()
end

---@private
function GA_Archer_01:S2C_OnMouseLeftCompleted_RPC1()
    log.dev('GA_Archer_01:OnMouseLeftCompleted()', net_util.print(self))
    ---@step montage jmp section
    -- self:MontageJumpToSection('Aim_End')
    self.Overridden.S2C_OnMouseLeftCompleted(self)
    
    ---@step 相机从越肩视角切换回普通视角
    if net_util.is_server(self) then
        local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
        pc.CameraViewComp:S2C_NewCameraViewModel('Normal')
    end
end

return GA_Archer_01