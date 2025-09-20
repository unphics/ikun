
---
---@brief   GameplayCue_GroundSurge
---@author  zys
---@data    Sat Sep 20 2025 13:35:13 GMT+0800 (中国标准时间)
---

---@class GCA_GroundSurge: AGameplayCueNotify_Actor
local GCA_GroundSurge = UnLua.Class()

function GCA_GroundSurge:OnActive(MyTarget, Parameters)
    local avatar = Parameters.Instigator
    local sys = UE.UObject.Load('/Game/Ikun/Chr/Mage/Mesh/Ice.Ice')
    local loc = avatar:K2_GetActorLocation()
    local rot = UE.FRotator(0, avatar:K2_GetActorRotation().Yaw, 0) 
    -- local niagara = UE.UNiagaraFunctionLibrary.SpawnSystemAtLocation(avatar, sys,
    --     loc, rot, UE.FVector(1,1,1), true, true, UE.ENCPoolMethod.None, true)
    -- niagara:SetDesiredAge(1)
    return true
end

return GCA_GroundSurge
