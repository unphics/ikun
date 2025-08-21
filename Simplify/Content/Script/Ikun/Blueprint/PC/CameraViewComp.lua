
---
---@brief   相机操作组件, 此组件挂在PlayerController上
---@author  zys
---@data    Mon Aug 11 2025 23:24:54 GMT+0800 (中国标准时间)
---

---@class CameraViewComp_C
local CameraViewComp = UnLua.Class()

-- function CameraViewComp:Initialize(Initializer)
-- end

-- function CameraViewComp:ReceiveBeginPlay()
-- end

-- function CameraViewComp:ReceiveEndPlay()
-- end

-- function CameraViewComp:ReceiveTick(DeltaSeconds)
-- end

---@public 相机新模式
function CameraViewComp:S2C_NewCameraViewModel_RPC(NewModelName)
    local cameraMgr = UE.UGameplayStatics.GetPlayerController(self, 0).PlayerCameraManager
    cameraMgr:NewCameraViewModel(NewModelName)
end

return CameraViewComp
