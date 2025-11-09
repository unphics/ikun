
---
---@brief Lich一技能, 远程
---@author zys
---@data Fri Jan 31 2025 14:13:55 GMT+0800 (中国标准时间)
---@deprecated
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class GA_Lich_Skill_02: BP_AbilityBase
local GA_Lich_Skill_02 = UnLua.Class('Ikun/Blueprint/GAS/Ability/BP_AbilityBase')

function GA_Lich_Skill_02:OnActivateAbility()
    self.Super.OnActivateAbility(self)

    ---@type UATPlayMtgAndWaitEvent
    local AT = UE.UATPlayMtgAndWaitEvent.PlayMtgAndWaitEvent(self, 'task name', 
        self.Mtg, UE.FGameplayTagContainer(),  1 , '', false, 1.0)
    AT.OnBlendOut:Add(self, self.OnCompleted)
    AT.OnCompleted:Add(self, self.OnCompleted)
    AT.OnInterrupted:Add(self, self.OnCancelled)
    AT.OnCancelled:Add(self, self.OnCancelled)
    AT.EventReceived:Add(self, self.OnEventReceived)
    AT:ReadyForActivation()
    self:RefUObject('AT', AT)
end

function GA_Lich_Skill_02:K2_OnEndAbility(WasCancelled)
    if net_util.is_server(self:GetAvatarActorFromActorInfo()) then
        -- if self.Ball and obj_util.is_valid(self.Ball) then
        --     self.Ball:K2_DestoryActor()
        --     self.Ball = nil
        -- end
        -- if self.TA and obj_util.is_valid(self.TA) then
        --     self.TA:K2_DestoryActor()
        --     self.TA = nil
        -- end
        -- if self.AT and obj_util.is_valid(self.AT) then
        --     self.AT:K2_DestoryActor()
        --     self.AT = nil
        -- end
    end
    self.Super.K2_OnEndAbility(self, WasCancelled)
end

function GA_Lich_Skill_02:OnEventReceived(EventTag, EventData)
    local SelfActor = self:GetAvatarActorFromActorInfo() ---@type BP_ChrBase
    if net_util.is_client(SelfActor) then
        return
    end
    if EventTag.TagName ~= UE.UIkunFnLib.RequestGameplayTag('Chr.Skill.Hit.01').TagName then
        return
    end
    local CurBT = SelfActor:GetRole().BT
    if not CurBT then
        return
    end
    local Target = CurBT.Blackboard:GetBBValue(BBKeyDef.FightTarget)
    if not Target then
        return
    end
    Target = Target.Avatar

    ---@type BP_Ball_Lich_02
    local Ball = actor_util.spawn_always(SelfActor, self.BallClass, SelfActor.SpawnPoint:K2_GetComponentToWorld())
    -- 修正投射物方向
    local Dir = Target:K2_GetActorLocation() - SelfActor:K2_GetActorLocation() ---@type FVector
    local Rot = UE.UKismetMathLibrary.Conv_VectorToRotator(Dir)
    Ball:K2_SetActorRotation(Rot, false)
    -- local ADC = UE.NewObject(UE.UApplyDataContainer)
    self.Ball = Ball

    Ball:InitBallByAbility(self, SelfActor,self.OnBallTrigger, self.OnBallDestroy)
end

function GA_Lich_Skill_02:OnBallDestroy()
    self:GAFail()
end

function GA_Lich_Skill_02:OnCompleted(EventTag, EventData)
    -- self:GASuccess()
end

function GA_Lich_Skill_02:OnCancelled(EventTag, EventData)
    self:GAFail()
end

function GA_Lich_Skill_02:OnBallTrigger(Actor, Transform)
    if not obj_util.is_valid(self) or not obj_util.is_valid(Actor) then
        return
    end
    self.Overridden.OnBallTrigger(self, Actor, Transform)
    do return end ---@todo zys 此处会触发crash, 只能调用蓝图了
        
    local SelfActor = self:GetAvatarActorFromActorInfo() ---@type AActor
    if not obj_util.is_valid(SelfActor) then
        return
    end
    local TargetActor = actor_util.spawn_always(SelfActor, self.TargetActorClass, Transform)

    local AbilityTask = UE.UAbilityTask_WaitTargetData.WaitTargetDataUsingActor(self, '', 
        UE.EGameplayTargetingConfirmation.Custom, TargetActor)
    -- local TargetingLocationInfo = UE.FGameplayAbilityTargetingLocationInfo() ---@type FGameplayAbilityTargetingLocationInfo
    -- TargetingLocationInfo.SourceActor = SelfActor
    -- TargetingLocationInfo.LocationType = UE.EGameplayAbilityTargetingLocationType.ActorTransform
    -- TargetActor.StartLocation = TargetingLocationInfo
    AbilityTask.ValidData:Add(self, self.OnTAValidData)
    AbilityTask:ReadyForActivation() -- 这个东西会调用Active
    self.AT = AbilityTask
    self.TA = TargetActor
    -- self:RefUObject('AbilityTask', AbilityTask)
    -- self:RefUObject('TargetActor', TargetActor)
end

function GA_Lich_Skill_02:OnTAValidData(Data, EventTag)
    local ActorArray = UE.UAbilitySystemBlueprintLibrary.GetAllActorsFromTargetData(Data) ---@type TArray
    local TargetActor = nil
    for i = 1, ActorArray:Length() do
        local Actor = ActorArray:Get(i)
        if Actor:IsA(UE.AGameplayAbilityTargetActor) then
            TargetActor = Actor
            ActorArray:Remove(Actor)
        end
    end
    -- log.debug(log.key.lich02boom, '爆炸波及敌人数量', tostring(ActorArray:Length()))
    local SelfActor = self:GetAvatarActorFromActorInfo() ---@type BP_ChrBase
    for i = 1, ActorArray:Length() do
        local Actor = ActorArray:Get(i)
        local isSelf = Actor == SelfActor
        local hitRole = Actor.GetRole and Actor:GetRole()
        local isEnemy = hitRole and SelfActor:GetRole():IsEnemy(Actor:GetRole())
        if not isSelf and hitRole and isEnemy then
            -- log.debug(log.key.lich02boom, '接收爆炸的敌人', Actor:GetRole():GetRoleId())
            local EffectContextHandle = self:GetContextFromOwner(Data)
            Actor:GetAbilitySystemComponent():BP_ApplyGameplayEffectToSelf(self.GameplayEffectClass, 1, EffectContextHandle)
        else
            -- log.debug(log.key.lich02boom, '...过滤的人', isSelf, rolelib.roleid(hitRole), isEnemy or 'nil')
        end
    end
    self:GASuccess()
end

return GA_Lich_Skill_02