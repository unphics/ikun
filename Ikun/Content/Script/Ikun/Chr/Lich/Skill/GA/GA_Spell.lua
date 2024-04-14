--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class GA_Spell: BP_IkunGA
local M = UnLua.Class('Ikun.Blueprint.GAS.GA.BP_IkunGA')

function M:OnActivateAbility()
    self.Overridden.OnActivateAbility(self)

    if not self.MontageToPlay then
        log.error('lich spell', 'failed to find montage')
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
    -- log.error('is server', self:GetAvatarActorFromActorInfo():HasAuthority())
    -- local player = UE.UGameplayStatics.GetPlayerPawn(self, 0)
    if self.OwnerChr:HasAuthority() and EventTag.TagName == UE.UIkunFuncLib.RequestGameplayTag('Chr.Skill.Spell').TagName then
        local Chr = self.OwnerChr
        if Chr then
            local LeftLoc = Chr.Mesh:GetSocketLocation('Wrist_L')
            local RightLoc = Chr.Mesh:GetSocketLocation('Wrist_R')
            local StartLoc = UE.FVector((LeftLoc.X + RightLoc.X) / 2, (LeftLoc.Y + RightLoc.Y) / 2, (LeftLoc.Z + RightLoc.Z) / 2)
            local EndLoc = Chr:GetActorForwardVector()
            local Rot = UE.UKismetMathLibrary.FindLookAtRotation(StartLoc, EndLoc)
            local Scale = UE.FVector(1, 1, 1)
            local Transform = UE.FTransform(UE.UIkunFuncLib.MakeQuatFromRot(Chr:GetControlRotation()), StartLoc, Scale)
            local SpawnParams = UE.FSpawnParamters()
            SpawnParams.CollisionHandling = UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn
            SpawnParams.Instigator = self.OwnerChr
            local ProjectileClass = UE.UClass.Load('/Game/Ikun/Chr/Lich/Skill/GA/Spell/BP_Spell.BP_Spell_C')
            local Projectile = UE.UIkunFuncLib.SpawnActor(self:GetWorld(), ProjectileClass, Transform, SpawnParams)
            if Projectile then
                Projectile.GE = self.GameplayEffectClass
            else
                log.error('failed to spawn projectile')
            end
        end
    end
end

return M