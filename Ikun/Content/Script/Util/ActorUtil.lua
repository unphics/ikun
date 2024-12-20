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

---@public 两个Actor之间没有障碍物(可投射判断)
actor_util.is_no_obstacles_between = function(actor_1, actor_2)
    local StartLoc = actor_1:K2_GetActorLocation()
    local EndLoc = actor_2:K2_GetActorLocation()
    local ETraceTypeQuery = UE.ETraceTypeQuery.Visibility
    local bComplex = false
    local ActorsToIgnore = UE.TArray(UE.AActor)
    local HitResults = UE.TArray(UE.FHitResult())
    local DebugLineType = UE.EDrawDebugTrace.None -- Persistent None
    UE.UKismetSystemLibrary.LineTraceMulti(actor_1:GetWorld(), StartLoc, EndLoc, ETraceTypeQuery, bComplex, ActorsToIgnore, DebugLineType, HitResults, true)
    if HitResults:Length() == 0 then
        return true
    else
        return false
    end
end

---@public 查找范围内所有Actor
---@param Loc FVector
---@param Range number
---@param FnFilter function<(Actor)>
actor_util.find_actors_in_range = function(World, Loc, Range, FnFilter)
    ---@todo
    -- UE.UKismetSystemLibrary.SphereTraceMulti(World,)
end

return actor_util