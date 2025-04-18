---
---@brief
---

---@class Ball_Lich_Skill_02: Ball_Lich_Skill_02_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

---@protected [ImplBP]
function M:ReceiveBeginPlay()
    self.Ability = nil
    self.Avatar = nil
    self.TriggerCB = nil
    self.Collision.OnComponentBeginOverlap:Add(self, self.OnCollisionComponentBeginOverlap)
end

---@protected [ImplBP]
function M:ReceiveEndPlay()
    self.Ability = nil
    self.Avatar = nil
    self.TriggerCB = nil
end

---@protected [ImplBP]
function M:ReceiveTick(DeltaSeconds)
    if self.DestroySelf then
        self.DestroySelf = false
        self:K2_DestroyActor()
    end
end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

---@private
function M:OnCollisionComponentBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if self.bBallTriggered then
        return
    end
    if net_util.is_client(self) then
        return
    end
    if self:CheckTarget(OtherActor) then
        log.log('Ball: overlap -> '..self:PrintRhsActor(OtherActor))
        self:ReturnResult(OtherActor)
    end
end

---@public
---@param Ability UGameplayAbility
---@param Avatar BP_ChrBase
---@param TriggerCB functon<AActor, FTransform>
function M:InitBallByAbility(Ability, Avatar, TriggerCB)
    self.Ability = Ability
    self.Avatar = Avatar
    self.TriggerCB = TriggerCB

    self.bAbilityDataInited = true
    self.DestroySelf = false

    if self.ArrActorBeforeAbilityDataInited then
        for i = 1, self.ArrActorBeforeAbilityDataInited:Length() do
            local OtherActor = self.ArrActorBeforeAbilityDataInited:Get(i)
            log.log('Ball: overlap '..self:PrintRhsActor(OtherActor))
            if self:CheckTarget(OtherActor) then ---@todo 这一段逻辑组织有点混乱, 有空重写一下
                self:ReturnResult(OtherActor)
            end
        end
    end
end

---@private
function M:CheckTarget(OtherActor)
    if OtherActor == self.Avatar then
        return false
    end
    if OtherActor == self then
        return false
    end
    if not self.bAbilityDataInited then
        if not self.ArrActorBeforeAbilityDataInited then
            self.ArrActorBeforeAbilityDataInited = UE.TArray(UE.AActor) ---@type TArray
        end
        self.ArrActorBeforeAbilityDataInited:AddUnique(OtherActor)
        return false
    end
    return true
end

---@private
function M:ReturnResult(OtherActor)
    local AvatarC = self.Ability:GetAvatarActorFromActorInfo() ---@type BP_ChrBase
    if not self.Ability then
        return log.error("Ball: 爆炸时自身状态错误! no self.Ability")
    end
    if not obj_util.is_valid(self) then
        return log.error("Ball: 爆炸时自身状态错误! invalid self")
    end
    if not obj_util.is_valid(AvatarC) then
        return log.error("Ball: 爆炸时自身状态错误! invalid SelfAvatar")
    end
    log.log('Ball: 爆炸成功 '..AvatarC:PrintRoleInfo()..self:PrintRhsActor(OtherActor))
    self.TriggerCB(self.Ability, OtherActor, self:GetTransform())
    self.bBallTriggered = true
    ---@note 避免crash, 延迟destory; 原因应该是某个相关的structure引用了此Actor
    self.DestroySelf = true
end

---@private 打印OtherActor
function M:PrintRhsActor(Actor)
    return Actor:IsA(UE.ACharacter) and Actor:PrintRoleInfo() or obj_util.dispname(Actor)
end

return M
