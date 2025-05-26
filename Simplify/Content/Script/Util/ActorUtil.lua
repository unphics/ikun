
---
---@brief UE的Actor相关的工具方法
---@author zys
---@data Sun May 04 2025 14:21:59 GMT+0800 (中国标准时间)
---

local actor_util = {}

local IkunChrClass = UE.UClass.Load('/Game/Ikun/Chr/Blueprint/BP_ChrBase.BP_ChrBase_C')

---@public 查找最近的ikun_chr
actor_util.get_nearby_ikun_chr = function(find_actor)
    local Actors = UE.TArray(IkunChrClass)
    UE.UGameplayStatics.GetAllActorsOfClass(find_actor, IkunChrClass, Actors)
    local NearbyActor = nil
    local NearbyDistance = nil
    if Actors:Length() > 1 then
        for i = 1, Actors:Length() do
            local Actor = Actors:Get(i)
            if UE.UKismetMathLibrary.NotEqual_ObjectObject(find_actor, Actor) then
                local Distance = Actor:GetDistanceTo(find_actor)
                if not NearbyDistance then
                    NearbyDistance = Distance
                    NearbyActor = Actor
                end
                if Distance < NearbyDistance then
                    NearbyActor = Actor
                end
            end
        end
    end
    return NearbyActor, NearbyDistance
end

---@public 两个Actor之间有障碍物(可投射判断)
---@param pos1 FVector | AActor
---@param pos2 FVector | AActor
---@return boolean
actor_util.has_obstacles = function(pos1, pos2,  allow_fn, fn)
    local world = world_util.GameWorld
    local StartLoc = pos1.IsA and pos1:K2_GetActorLocation() or pos1
    local EndLoc = pos2.IsA and pos2:K2_GetActorLocation() or pos2
    local ETraceTypeQuery = UE.ETraceTypeQuery.Visibility
    local bComplex = false
    local ActorsToIgnore = UE.TArray(UE.AActor)
    local HitResults = UE.TArray(UE.FHitResult())
    local DebugLineType = UE.EDrawDebugTrace.None -- Persistent None
    -- local Dir = EndLoc - StartLoc
    -- Dir:Normalize()
    -- Dir = Dir * -300
    -- StartLoc = StartLoc + Dir
    UE.UKismetSystemLibrary.LineTraceMulti(world, StartLoc, EndLoc, ETraceTypeQuery, bComplex, ActorsToIgnore,
        DebugLineType, HitResults, true, UE.FLinearColor(), UE.FLinearColor(), 1)
    local tb = {}
    for i = 1, HitResults:Length() do
        local Actor = HitResults:Get(i).HitObjectHandle.Actor
        if allow_fn then
            if not allow_fn(Actor) then
                table.insert(tb, Actor)
            end
        else
            table.insert(tb, Actor)
        end
    end
    if fn then
        fn(tb)
    end
    if #tb > 0 then
        return true
    else
        return false
    end
end

---@public 查找范围内所有Actor
---@param Loc FVector
---@param Range number
---@param FnFilter function(AActor>)
---@return UE.TArray<UE.AActor>
actor_util.find_actors_in_range = function(Actor, Loc, Range, FnFilter)
    ---@todo
    local ResultHits = UE.TArray(UE.FHitResult)
    local Ignore = UE.TArray(UE.AActor)
    Ignore:Add(Actor)
    -- local TraceChannel = UE.ETraceTypeQuery.TraceTypeQuery8
    -- local TraceChannel = UE.ECollisionChannel.ECC_Visibility
    -- UE.UKismetSystemLibrary.SphereTraceMulti(Actor,Loc, Loc, Range,
    -- TraceChannel, false, Ignore, 0,
    --     ResultHits, true, UE.FLinearColor(1, 0, 0, 1))

    local ObjectTypes = UE.TArray(UE.EObjectTypeQuery)
    -- ObjectTypes:Add(UE.UClass.Load('/Game/Ikun/Chr/Lich/Blueprint/BP_Lich.BP_Lich_C'))
    ObjectTypes:Add(UE.EObjectTypeQuery.Pawn)
    ObjectTypes:Add(UE.EObjectTypeQuery.CharacterMesh)
    UE.UKismetSystemLibrary.SphereTraceMultiForObjects(Actor,Loc, Loc, Range,
    ObjectTypes, false, Ignore, 0, ResultHits, true, 
        UE.FLinearColor(1, 0, 0, 1), UE.FLinearColor(1, 0, 0, 1), 0)
        
    local OutHits = UE.TArray(UE.AActor) ---@type TArray
    if ResultHits:Length() > 0 then 
        for i = 1, ResultHits:Length() do
            local Result = ResultHits:Get(i) ---@type FHitResult
            local HitObject = Result.HitObjectHandle.Actor
            if not HitObject then
                goto continute
            end
            local HitActor = nil
            if HitObject.IsA and (HitObject:IsA(UE.AActor)) then
                HitActor = HitObject
            elseif HitActor.GetOwner and HitObject:GetOwner():IsA(UE.AActor) then
                HitActor = HitObject:GetOwner()
            end
            if not HitActor then
                goto continute
            end
            if FnFilter and not FnFilter(HitActor) then
                goto continute
            end
            OutHits:AddUnique(HitActor)
            ::continute::
        end
    end
    return OutHits
end

---@public
---@param World UWorld | AActor
---@param Transform FTransform
actor_util.spawn_always = function(World, Class, Transform)
    if not World then
        return
    end
    local WorldCtx = World
    if WorldCtx.GetWorld then
        WorldCtx = WorldCtx:GetWorld()
    end
    local Actor = WorldCtx:GetWorld():SpawnActor(Class, Transform, UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    if not Actor then
        log.error('Failed to spawn in actor_util.spawn_always', debug.traceback())
    end
    return Actor
end

---@public
---@param OwnerChr BP_ChrBase
actor_util.filter_is_firend_4_obstacles = function(OwnerChr)
    local OwnerRole = OwnerChr:GetRole()
    local function filter(HitActor)
        if not HitActor.GetRole then
            return true
        end
        local HitRole = HitActor:GetRole()
        if not HitRole then
            return
        end
        if OwnerRole:IsFirend(HitRole) then
            -- log.dev('line trace =================== firend', owner, owner:GetDisplayName(), role:GetDisplayName())
            return true
        end
        -- log.dev('line trace =================== enemy', owner, owner:GetDisplayName(), role:GetDisplayName())
        return false
    end
    return filter
end

return actor_util