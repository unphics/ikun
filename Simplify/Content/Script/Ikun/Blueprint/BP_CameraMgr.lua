
---
---@brief   CameraMgr
---@author  zys
---@data    Thu Jul 17 2025 00:48:50 GMT+0800 (中国标准时间)
---

---@class BP_CameraMgr: BP_CameraMgr_C
local BP_CameraMgr = UnLua.Class()

function BP_CameraMgr:ReceiveBeginPlay()
    self.PC = UE.UGameplayStatics.GetPlayerController(self, 0)
end

---@notice 此函数在cpp中为<bool(AActor, out FVector, out FRotator, out number)>, 但是在lua中要3个out参数要在第一个返回值bool后返回出去
---@param CameraTarget APawn
---@return boolean, FVector, FRotator, number
function BP_CameraMgr:BlueprintUpdateCamera(CameraTarget)
    if obj_util.is_valid(CameraTarget) and obj_util.is_valid(self.PC) then
        local rot = self.PC:GetControlRotation()
        local loc = CameraTarget:K2_GetActorLocation()
        loc = loc + (rot:GetForwardVector() * -300)
        loc = loc + (rot:GetRightVector() * 1)
        loc = loc + (rot:GetUpVector() * 100)
        return true, loc, rot, 90
    end
    return false, UE.FVector(), UE.FRotator(), 90
end

return BP_CameraMgr