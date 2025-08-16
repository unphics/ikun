
---
---@brief   主角-弓箭手
---@author  zys
---@data    Thu Jul 31 2025 23:26:44 GMT+0800 (中国标准时间)
---

local ArrowClass = UE.UClass.Load('/Game/Ikun/Chr/Archer/BP_Arrow.BP_Arrow_C')

---@class BP_Archer: BP_Archer_C
local BP_Archer = UnLua.Class('Ikun/Chr/Blueprint/BP_ChrBase')

---@override
function BP_Archer:ReceiveBeginPlay()
    self.Super.ReceiveBeginPlay(self)
    -- self.ASC.OnTagChanged:Add(self,function(this, tag, bexist)
    --     log.dev('[OnTagChanged]', tag.TagName, bexist)
    -- end)
end

---@override
function BP_Archer:ReceiveTick(DeltaSeconds)
    self.Super.ReceiveTick(self, DeltaSeconds)
end

---@public PC会调用此方法
---@todo 考虑其实PC不需要调用这个，而是直接执行
function BP_Archer:C2S_LeftStart_RPC()
    local _, handle = gas_util.get_all_active_abilities(self)
    local result = self.ASC:TryActivateAbility(handle[1], true)
    self.pull = true
end

---@public PC会调用此方法
function BP_Archer:C2S_LeftEnd_RPC()
    if not self.pull then
        return
    end
    self.pull = false
    -- gas_util.add_loose_tag(self, 'Input.MouseLeft.Completed')
    -- log.dev('BP_Archer:C2S_LeftEnd_RPC()', net_util.print(self), gas_util.has_loose_tag(self, 'Input.MouseLeft.Completed'))
    UE.UAbilitySystemBlueprintLibrary.SendGameplayEventToActor(self, UE.UIkunFnLib.RequestGameplayTag('Input.MouseLeft.Completed'), nil)
end

function BP_Archer:ArcherShoot()
    local locBow = self.Bow:GetSocketLocation('Bow_String') -- self.Bow:GetSocketTransform('Bow_String', UE.ERelativeTransformSpace.RTS_World)
    local rotChr = self:K2_GetActorRotation()
    self:C2S_ArcherShoot(UE.FTransform(rotChr:ToQuat(), locBow))
end

function BP_Archer:C2S_ArcherShoot_RPC(trans)
    actor_util.spawn_always(self, ArrowClass, trans)
end

return BP_Archer