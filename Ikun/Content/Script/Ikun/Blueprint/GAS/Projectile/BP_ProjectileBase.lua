
---
---@brief   投射物
---@author  zys
---@data    Sat Sep 06 2025 12:30:40 GMT+0800 (中国标准时间)
---

---@class BP_ProjectileBase: BP_ProjectileBase_C
---@field AbilityContext AbilityContext
local BP_ProjectileBase = UnLua.Class()

---@override
function BP_ProjectileBase:ReceiveBeginPlay()
    self.CollisionPawn.OnComponentBeginOverlap:Add(self, self.OnCollisionPawnBeginOverlap)
    self.CollisionEnv.OnComponentBeginOverlap:Add(self, self.OnCollisionEnvBeginOverlap)
end

---@override
function BP_ProjectileBase:ReceiveEndPlay()
    self.CollisionPawn.OnComponentBeginOverlap:Clear()
    self.CollisionEnv.OnComponentBeginOverlap:Clear()
end

---@override
function BP_ProjectileBase:ReceiveTick(DeltaSeconds)
    -- self:DrawArrowPath(DeltaSeconds)
end

---@public [Server] 初始化投射物的发射者
---@param AbilityContext AbilityContext
function BP_ProjectileBase:InitProjectile(AbilityContext)
    self.AbilityContext = AbilityContext
    self.Shooter = AbilityContext.Avatar
end

---@private [Draw] 绘制箭矢的路径
function BP_ProjectileBase:DrawArrowPath(DeltaTime)
    if net_util.is_server(self) then
        return
    end
    local interval = 0.05
    if not self.curtime then
        self.curtime = DeltaTime
    else
        self.curtime = self.curtime + DeltaTime
    end
    if self.curtime > interval then
        self.curtime = self.curtime - interval
        UE.UKismetSystemLibrary.DrawDebugSphere(self, self:K2_GetActorLocation(), 40, 6, UE.FLinearColor(0, 0, 1), 10, 3)
    end
end

---@private
function BP_ProjectileBase:OnCollisionEnvBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if self.Shooter == OtherActor then
        return
    end
    self:TriggerProjectileHit(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    self:StopAndStatic()
end

---@private
function BP_ProjectileBase:OnCollisionPawnBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not obj_util.is_valid(self.Shooter) then
        return
    end
    if self.Shooter == OtherActor then
        return
    end
    self:TriggerProjectileHit(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    self:StopAndStatic()
end

---@private 停止和静态化
function BP_ProjectileBase:StopAndStatic()
    self.ProjectileMovement:StopMovementImmediately()
    self.ProjectileMovement.ProjectileGravityScale = 0
    self.CollisionPawn:SetGenerateOverlapEvents(false)
    self.CollisionPawn.OnComponentBeginOverlap:Clear()
    self.CollisionEnv.OnComponentBeginOverlap:Clear()
end

---@private [Server]
---@param OverlappedComponent UPrimitiveComponent
---@param OtherActor AActor
---@param OtherComp UPrimitiveComponent
---@param OtherBodyIndex integer
---@param bFromSweep boolean
---@param SweepResult FHitResult
function BP_ProjectileBase:TriggerProjectileHit(OverlappedComponent, OtherActor, 
    OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if net_util.is_client(self) then
        return
    end
    -- local targetActorClass = ''
    -- local transform = UE.FTransform(self:K2_GetActorRotation():ToQuat(), SweepResult.ImpactPoint)
    -- local targetActor = actor_util.spawn_always(self, targetActorClass, transform)
    -- local at = UE.UAbilityTask_WaitTargetData.WaitTargetDataUsingActor(self.AbilityContext.Ability, '',
    --     UE.EGameplayTargetingConfirmation.Custom, targetActor)

    local loc = self:K2_GetActorLocation()
    local radius = 50
    local objTypes = {UE.EObjectTypeQuery.Pawn}
    local ignores = {self, self.Shooter}
    local hitResults = UE.TArray(UE.FHitResult)
    local traceColor = UE.FLinearColor(1, 0, 0)
    local hitColor = UE.FLinearColor(0, 1, 0)
    local bResult = UE.UKismetSystemLibrary.SphereTraceMultiForObjects(self, loc, loc, radius,
        objTypes, false, ignores, UE.EDrawDebugTrace.ForDuration,
        hitResults, true, traceColor, hitColor, 3)
    if bResult then
        if hitResults:Get(1) and hitResults:Get(1).HitObjectHandle and hitResults:Get(1).HitObjectHandle.Actor then 
            local target = hitResults:Get(1).HitObjectHandle.Actor
            local asc = self.Shooter.ASC ---@type UIkunASC
            local effectContextHandle = asc:MakeEffectContext()
            local obj = obj_util.new_uobj()
            local config = self.AbilityContext.SkillConfig ---@type SkillConfig
            obj.EffectCtx = {
                SkillConfig = config,
            }
            UE.UIkunFnLib.SetEffectContextOpObj(effectContextHandle, obj)
            local effectName = config.SkillEffects[1]
            local effectClass = gas_util.find_effect_class(effectName)
            target:GetAbilitySystemComponent():BP_ApplyGameplayEffectToSelf(effectClass, 1, effectContextHandle)
        end
    end
end

return BP_ProjectileBase