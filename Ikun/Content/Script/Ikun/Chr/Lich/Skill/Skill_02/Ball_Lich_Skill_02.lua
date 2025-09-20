---
---@brief   Lich二技能的投射物
---@author  zys
---@data    Sun Jul 06 2025 17:32:54 GMT+0800 (中国标准时间)
---

---@class Ball_Lich_Skill_02: Ball_Lich_Skill_02_C
---@field ConstAliveTime number 投射物最大存活时间
---@field CurLiveTime number 投射物当前存活时间
---@field OwnerAbility BP_AbilityBase 所属技能
---@field OwnerAvatar BP_ChrBase 所属角色
---@field TriggerCB fun(BP_AbilityBase, AActor, FTransform) 投射物碰撞回调
---@field bDestroySelf boolean 需要销毁自己
local M = UnLua.Class()

---@override
function M:ReceiveBeginPlay()
    self.ConstAliveTime = 7
    self.CurLiveTime = 0
    self.OwnerAbility = nil
    self.OwnerAvatar = nil
    self.TriggerCB = nil
    self.bDestroySelf = false
    self.Collision.OnComponentBeginOverlap:Add(self, self.OnCollisionComponentBeginOverlap)
end

---@override
function M:ReceiveTick(DeltaSeconds)
    self.CurLiveTime = self.CurLiveTime + DeltaSeconds
    if self.CurLiveTime > self.ConstAliveTime then
        self.bDestroySelf = true
    end
    if self.bDestroySelf then
        if self.DestroyCB then
            self.DestroyCB(self.OwnerAbility)
            self.DestroyCB = nil
        end
        self.bDestroySelf = false
        self:K2_DestroyActor()
    end
end

---@private
function M:OnCollisionComponentBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if self.bBallTriggered then
        return
    end
    if net_util.is_client(self) then
        return
    end
    if self:CheckTarget(OtherActor) then
        -- log.debug(log.key.lich02boom, 'Ball: overlap -> '..self:PrintRhsActor(OtherActor))
        self:ReturnResult(OtherActor)
    end
end

---@public
---@param OwnerAbility UGameplayAbility
---@param OwnerAvatar BP_ChrBase
---@param TriggerCB fun(BP_AbilityBase, AActor, FTransform)
function M:InitBallByAbility(OwnerAbility, OwnerAvatar, TriggerCB, DestroyCB)
    -- log.dev('M:InitBallByAbility', OwnerAbility, self)
    self.OwnerAbility = OwnerAbility
    self.OwnerAvatar = OwnerAvatar
    self.TriggerCB = TriggerCB
    self.DestroyCB = DestroyCB

    self.bAbilityDataInited = true
    self.bDestroySelf = false

    if self.ArrActorBeforeAbilityDataInited then
        for i = 1, self.ArrActorBeforeAbilityDataInited:Length() do
            local OtherActor = self.ArrActorBeforeAbilityDataInited:Get(i)
            -- log.debug('Ball: overlap '..self:PrintRhsActor(OtherActor))
            if self:CheckTarget(OtherActor) then ---@todo 这一段逻辑组织有点混乱, 有空重写一下
                self:ReturnResult(OtherActor)
            end
        end
    end
end

---@private
function M:CheckTarget(OtherActor)
    if OtherActor == self.OwnerAvatar then
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
    local AvatarC = self.OwnerAbility.AvatarLua ---@type BP_ChrBase
    local bValid, invalidIdx = obj_util.all_valid(self.OwnerAbility, self, AvatarC)
    if not bValid then
        return log.error(log.key.lich02boom, 'Ball: 爆炸时自身状态错误!!!', invalidIdx)
    end
    log.debug(log.key.lich02boom, '爆炸成功', '自己='..rolelib.roleid(AvatarC), '对方='..rolelib.roleid(OtherActor), '-------------------')
    self.TriggerCB(self.OwnerAbility, OtherActor, self:GetTransform())
    self.bBallTriggered = true
    ---@note 避免crash, 延迟destory; 原因应该是某个相关的structure引用了此Actor
    self.bDestroySelf = true
end

---@private 打印OtherActor
function M:PrintRhsActor(Actor)
    return Actor:IsA(UE.ACharacter) and Actor:PrintRoleInfo() or obj_util.dispname(Actor)
end

return M
