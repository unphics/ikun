

local Class3 = require('Core/Class/Class3')

---@class TargetLibClass
local TargetLibClass = Class3.Class("TargetLibClass")

---@public
---@param InWorldContext UObject
---@param InSpherCenter FVector 
---@param InRadius number
---@param InObjTypes integer[]
---@param InIgnoreActors AActor[]
---@return TArray<FHitResult>
function TargetLibClass.MakeSphereInst(InWorldContext, InSpherCenter, InRadius, InObjTypes, InIgnoreActors)
    local hits = UE.TArray(UE.FHitResult)
    UE.UKismetSystemLibrary.SphereTraceMultiForObjects(InWorldContext, InSpherCenter, InSpherCenter, InRadius,
        InObjTypes, false, InIgnoreActors, UE.EDrawDebugTrace.ForDuration, hits, false, UE.FLinearColor(1, 0, 0, 1),
        UE.FLinearColor(0, 1, 0, 1), 5)
    return hits
end

return TargetLibClass