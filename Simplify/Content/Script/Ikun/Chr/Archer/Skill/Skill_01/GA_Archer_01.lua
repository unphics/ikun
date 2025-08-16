
---
---@brief   弓箭手技能1
---@author  zys
---@data    Wed Aug 13 2025 20:39:21 GMT+0800 (中国标准时间)
---

local StarConfig = require("Content.Area.Config.StarConfig")
local ArrowClass = UE.UClass.Load('/Game/Ikun/Chr/Archer/BP_Arrow.BP_Arrow_C')

---@class GA_Archer_01: GA_IkunBase
local GA_Archer_01 = UnLua.Class('Ikun/Blueprint/GAS/GA_IkunBase')

---@override
function GA_Archer_01:OnActivateAbility()
    self.Super.OnActivateAbility(self)
    log.info(log.key.archer01, 'GA_Archer_01:OnActivateAbility()', net_util.print(self))

    ---@step 播放蒙太奇动作
    local at = UE.UATPlayMtgAndWaitEvent.PlayMtgAndWaitEvent(self, 'task name',
        self.MtgShoot, UE.FGameplayTagContainer(), 1, '', false, 1)
    at.OnBlendOut:Add(self, self.OnMtgCompleted)
    at.OnCompleted:Add(self, self.OnMtgCompleted)
    at.OnInterrupted:Add(self, self.OnMtgCancelled)
    at:ReadyForActivation()
    self:RefTask(at)
    
    ---@step 等待鼠标左键松开事件
    if net_util.is_server(self) then
        local tag = UE.UIkunFnLib.RequestGameplayTag('Input.MouseLeft.Completed')
        local stopTask = UE.UAbilityTask_WaitGameplayEvent.WaitGameplayEvent(self, tag, nil, true, true)
        stopTask.EventReceived:Add(self, self.OnMouseLeftCompleted)
        stopTask:ReadyForActivation()
        self:RefTask(stopTask)
    end

    ---@step 等待松手动画开始时发射箭矢
    if net_util.is_server(self) then
        local tag = UE.UIkunFnLib.RequestGameplayTag('Skill.Tag.Shoot')
        local shootTask = UE.UAbilityTask_WaitGameplayEvent.WaitGameplayEvent(self, tag, nil, true, true)
        shootTask.EventReceived:Add(self, self.OnAnimShoot)
        shootTask:ReadyForActivation()
        self:RefTask(shootTask)
    end

    ---@step 相机切换到越肩视角
    if net_util.is_server(self) then
        local ctlr = self.AvatarLua:GetController()
        if ctlr and ctlr.CameraViewComp then
            ctlr.CameraViewComp:S2C_NewCameraViewModel('Aim')
        end
    end

    async_util.timer(self, self.OnTimerCall, 1, true)
end

---@private
function GA_Archer_01:OnTimerCall()
    self.AvatarLua.InFightComp:C2S_FallInFight()
end

---@override
function GA_Archer_01:K2_OnEndAbility(WasCancelled)
    self.Overridden.K2_OnEndAbility(self, WasCancelled)
end

---@private [Server] [Client] 拉弓动画完成后技能释放成功
function GA_Archer_01:OnMtgCompleted()
    self:GASuccess()
end

---@private [Server] [Client] 拉弓动画取消后技能释放失败
---@todo 如果已经释放了箭矢就算成功
function GA_Archer_01:OnMtgCancelled()
    self:GAFail()
end

---@private [Server]
function GA_Archer_01:OnMouseLeftCompleted()
    self:S2C_OnMouseLeftCompleted()
end

---@private [Server] [Client]
function GA_Archer_01:S2C_OnMouseLeftCompleted_RPC()
    log.info(log.key.archer01, 'GA_Archer_01:OnMouseLeftCompleted()', net_util.print(self))
    ---@step montage jmp section
    self:MontageJumpToSection('Aim_End')
    
    ---@step 相机从越肩视角切换回普通视角
    if net_util.is_server(self) then
        local ctlr = self.AvatarLua:GetController()
        if ctlr and ctlr.CameraViewComp then
            ctlr.CameraViewComp:S2C_NewCameraViewModel('Normal')
        end
    end
end

---@private [Server]
function GA_Archer_01:OnAnimShoot()
    local shootLoc = self.AvatarLua.Bow:GetSocketLocation('Bow_String')
    local upDir = self.AvatarLua:GetActorUpVector()
    shootLoc = shootLoc + upDir * 60
    local shootRot = self.AvatarLua:GetControlRotation()
    local shootTansform = UE.FTransform(shootRot:ToQuat(), shootLoc)
    actor_util.spawn_always(self.AvatarLua, ArrowClass, shootTansform)
end

return GA_Archer_01