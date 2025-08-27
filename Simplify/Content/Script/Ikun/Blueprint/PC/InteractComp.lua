
---
---@brief   交互组件
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
    self.GazeIntervalConst = MdMgr.ConfigMgr:GetGlobalConst('GazeInterval')
    self.GazeDistanceConst = MdMgr.ConfigMgr:GetGlobalConst('GazeDistance')
    self.CurGazeCountTime = 0
end

---@override
function GazeComp:ReceiveTick(DeltaSeconds)
    self:Gazing(DeltaSeconds)
end

---@private [Gaze] [Client] 注视物体
---@param DeltaTime number
function GazeComp:Gazing(DeltaTime)
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
    self:C2S_ReqUpdateGazing(hitResult.HitObjectHandle.Actor)
end

---@private [Gaze] [Server] 客户端请求更新当前注视的物体
---@todo 增加Check
---@param InteractActor AActor
function GazeComp:C2S_ReqUpdateGazing_RPC(InteractActor)
    if self.bInteracting then
        return
    end
    self.Rep_GazeName = ''
    if obj_util.is_valid(InteractActor) then
        self.Rep_InteractActor = InteractActor
        local role = rolelib.role(self.Rep_InteractActor)
        if role then
            self.Rep_GazeName = role:GetRoleDispName()
        end
    end
end

---@public
function GazeComp:C2S_ReqInteractGaze_RPC()
    ---@todo check
    ---@todo 如果是物体就执行拾取等, 如果是人就开始对话, 此时默认是人
    self:GetOwner().ChatComp:BeginChat(self.Rep_InteractActor)
end





---@private 服务端对交互请求的回复
function GazeComp:S2C_RspInteract_RPC()
    ---@todo 客户端没有Role
    if not net_util.is_server(self) then
        return
    end
    local ui = ui_util.uimgr:GetUIIfVisible(ui_util.uidef.Interact) ---@type UI_Interact
    if ui then
        if obj_util.is_valid(self.Rep_InteractActor) then
            local name = nil
            local role = rolelib.role(self.Rep_InteractActor)
            if role then
                name = role:GetRoleDispName()
            else
                name = obj_util.dispname(self.Rep_InteractActor)
            end
            ui:InitInteract(name, 41001)
        else
            ui:InitInteract('', nil)
        end
    end
end

---@public 进入交互状态
function GazeComp:C2S_ReqInteractBegin_RPC()
    self.bInteracting = true
end

---@public 退出交互状态
function GazeComp:C2S_ReqInteractEnd_RPC()
    self.bInteracting = false
end

---@public [Pure]
function GazeComp:GetGazeName()
    return self.Rep_GazeName
end

return GazeComp