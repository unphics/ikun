
---
---@brief   CameraMgr
---@author  zys
---@data    Thu Jul 17 2025 00:48:50 GMT+0800 (中国标准时间)
---

---@class CameraViewConfig
---@field Forward number
---@field Right number
---@field Up number

---@class BP_CameraMgr: BP_CameraMgr_C
---@field CurCameraLoc FVector
---@field TargetCameraLoc FVector
---@field CameraTransitionTotalTime number
---@field bCameraFading boolean
---@field CameraViewConfig CameraViewConfig
local BP_CameraMgr = UnLua.Class()

---@override
function BP_CameraMgr:ReceiveBeginPlay()
    self.PC = UE.UGameplayStatics.GetPlayerController(self, 0)

    self:NewCameraViewModel('Normal')
    self.CurCameraLoc = self.TargetCameraLoc
end

---@override
function BP_CameraMgr:ReceiveTick(DeltaTime)
    if self.bCameraFading then
        local newLoc = self:SmoothStepMove(self.CurCameraLoc, self.TargetCameraLoc, self.CameraTransitionTotalTime, DeltaTime) 
        self.CurCameraLoc = newLoc
        if UE.UKismetMathLibrary.VSizeSquared(newLoc - self.TargetCameraLoc) < 1e-4 then
            self.bCameraFading = false
        end
    end
end

---@override
---@notice 此函数在cpp中为<bool(AActor, out FVector, out FRotator, out number)>, 但是在lua中要3个out参数要在第一个返回值bool后返回出去
---@param CameraTarget APawn
---@return boolean, FVector, FRotator, number
function BP_CameraMgr:BlueprintUpdateCamera(CameraTarget)
    if obj_util.is_valid(CameraTarget) and obj_util.is_valid(self.PC) then
        local rot = self.PC:GetControlRotation()
        local loc = CameraTarget:K2_GetActorLocation()
        loc = loc + (rot:GetForwardVector() * self.CurCameraLoc.X)
        loc = loc + (rot:GetRightVector() * self.CurCameraLoc.Y)
        loc = loc + (rot:GetUpVector() * self.CurCameraLoc.Z)
        return true, loc, rot, 90
    end
    return false, UE.FVector(), UE.FRotator(), 90
end

---@public 进入一个新的相机模式
function BP_CameraMgr:NewCameraViewModel(NewModelName)
    local cfg = self:GetModelCfg(NewModelName) ---@type CameraViewConfig
    if not cfg then
        return log.error('BP_CameraMgr:NewCameraViewModel() 使用了未定义的模式', NewModelName)
    end
    self.TargetCameraLoc = UE.FVector(cfg.Forward, cfg.Right, cfg.Up)
    self.CameraTransitionTotalTime = ConfigMgr:GetGlobalConst('CameraTransitionTime')
    self.bCameraFading = true
end

---@private 根据模式名字获取该模式的配置信息
---@return CameraViewConfig
function BP_CameraMgr:GetModelCfg(ModelName)
    local config = ConfigMgr:GetConfig('CameraViewModel')
    return config[ModelName]
end

---@private
---@param CurrentLoc FVector 当前相机位置
---@param TargetLoc FVector 目标位置
---@param TotalTime number 规定完成插值的总时间（秒）
---@param DeltaSeconds number 本帧经过时间（秒）
---@return FVector NewLoc
function BP_CameraMgr:SmoothStepMove(CurrentLoc, TargetLoc, TotalTime, DeltaSeconds)
    local Alpha = UE.UKismetMathLibrary.FClamp(DeltaSeconds / TotalTime, 0, 1)
    local NewLoc = UE.UKismetMathLibrary.VLerp(CurrentLoc, TargetLoc, Alpha)
    return NewLoc
end

return BP_CameraMgr