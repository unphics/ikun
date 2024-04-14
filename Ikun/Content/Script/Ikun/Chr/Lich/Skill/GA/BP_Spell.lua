--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BP_Spell_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    if self:HasAuthority() then
        log.log('lich spell begin play')
        self.SphereComp.OnComponentBeginOverlap:Add(self, self.SphereComp_OnBeginOverlap)
        self.SphereComp.OnComponentEndOverlap:Add(self, self.SphereComp_OnEndOverlap)
    end
end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

function M:SphereComp_OnBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    log.log('succeed to begin overlap other actor')
    if self:GetInstigator() == OtherActor then
        return
    end
    local IkunChr = OtherActor:Cast(UE.AIkunChrBase)
    if not IkunChr then
        return
    end
    if self.GE then
        IkunChr:GetAbilitySystemComponent():BP_ApplyGameplayEffectToSelf(self.GE, 1, UE.FGameplayEffectContextHandle())
    else
        log.error('failed to find GE')
    end
    self:K2_DestroyActor()
end

function M:SphereComp_OnEndOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
end
return M
