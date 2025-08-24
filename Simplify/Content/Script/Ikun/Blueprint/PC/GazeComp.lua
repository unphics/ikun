
---
---@brief   凝视组件
---@author  zys
---@data    Sat Aug 23 2025 11:23:32 GMT+0800 (中国标准时间)
---

local EnhInput = require('Ikun/Module/Input/EnhInput')
local InputMgr = require("Ikun/Module/Input/InputMgr")

---@class GazeComp: GazeComp_C
---@field GazeIntervalConst number 凝视间隔
---@field GazeDistanceConst number 凝视距离
---@field CurGazeCountTime number 当前凝视时间计时
local GazeComp = UnLua.Class()

---@override
function GazeComp:ReceiveBeginPlay()
    self.GazeIntervalConst = MdMgr.CfgMgr:GetGlobalConst('GazeInterval')
    self.GazeDistanceConst = MdMgr.CfgMgr:GetGlobalConst('GazeDistance')
    self.CurGazeCountTime = 0

    self:InterInteractInput()
end

---@override
function GazeComp:ReceiveTick(DeltaSeconds)
    self:TayGazing(DeltaSeconds)
end

---@private
---@param DeltaTime number
function GazeComp:TayGazing(DeltaTime)
    if net_util.is_server(self) then
        return
    end
    self.CurGazeCountTime = self.CurGazeCountTime + DeltaTime
    if self.CurGazeCountTime < self.GazeIntervalConst then
        return
    end
    self.CurGazeCountTime = self.CurGazeCountTime - self.GazeIntervalConst
    
    local cameraMgr = UE.UGameplayStatics.GetPlayerCameraManager(self:GetOwner(), 0)
    local cameraLoc = cameraMgr:K2_GetActorLocation()
    local cameraFwd = cameraMgr:GetActorForwardVector()
    local ignores = UE.TArray(UE.AActor)
    local hitResult = UE.FHitResult() -- UE.TArray(UE.FHitResult)
    local result = UE.UKismetSystemLibrary.LineTraceSingle(self:GetOwner(), cameraLoc,
        cameraLoc + cameraFwd * self.GazeDistanceConst, UE.ETraceTypeQuery.Visibility,
            false, ignores, UE.EDrawDebugTrace.None,
            hitResult, true, UE.FLinearColor(1, 0, 0),
            UE.FLinearColor(0, 1, 0), 1)
    if result then
        local actor = hitResult.HitObjectHandle.Actor
        if obj_util.is_valid(actor) then
            self:C2S_ReqInteract(actor)
        end
    end
end

---@private 客户端请求与该Actor交互
---@param InteractActor AActor
function GazeComp:C2S_ReqInteract_RPC(InteractActor)

end

---@private
function GazeComp:InterInteractInput()
    EnhInput.AddIMC(EnhInput.IMCDef.IMC_Interact)
end

return GazeComp