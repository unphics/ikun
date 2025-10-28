
---
---@brief   交互组件
---@author  zys
---@data    Sat Aug 23 2025 11:23:32 GMT+0800 (中国标准时间)
---

---@class InteractComp: InteractComp_C
---@field GazeIntervalConst number 凝视间隔
---@field GazeDistanceConst number 凝视距离
---@field CurGazeCountTime number 当前凝视时间计时
local InteractComp = UnLua.Class()

---@override
function InteractComp:ReceiveBeginPlay()
    self.GazeName = ''
    self.InteractActor = nil
    self.GazeIntervalConst = ConfigMgr:GetGlobalConst('GazeInterval')
    self.GazeDistanceConst = ConfigMgr:GetGlobalConst('GazeDistance')
    self.CurGazeCountTime = 0
end

---@override
function InteractComp:ReceiveTick(DeltaSeconds)
    self:_Gazing(DeltaSeconds)
end

---@public [Input] [Server]
function InteractComp:C2S_ReqInteractGaze_RPC()
    if not self:_CanInteract() then
        return
    end
    ---@todo check
    ---@todo 如果是物体就执行拾取等, 如果是人就开始对话, 此时默认是人
    if self:GetOwner().ChatComp:BeginChat(self.InteractActor) then
        self:EnterInteract()
    end
end

---@public 进入交互状态
function InteractComp:EnterInteract()
    local target = self:GetInteractTarget()
    if not obj_util.is_valid(target) then
        return log.error(log.key.chat, 'InteractComp:EnterInteract 尝试交互无效的目标')
    end
    local receptionComp = target:GetController().BP_ReceptionComp ---@as BP_ReceptionComp
    if not receptionComp then
        return log.error(log.key.chat, 'InteractComp:EnterInteract 交互的目标没有接待组件', target)
    end
    receptionComp:BeginVisitNpc(self:GetOwner())
    self.bInteracting = true
end

---@public 退出交互状态
function InteractComp:QuitInteract()
    self.bInteracting = false
    local target = self:GetInteractTarget()
    if not obj_util.is_valid(target) then
        return log.warn(log.key.chat, 'InteractComp:QuitInteract 结束交互时目标已经失效')
    end
    local receptionComp = target:GetController().BP_ReceptionComp ---@as BP_ReceptionComp
    receptionComp:EndVisitNpc(self:GetOwner())
end

---@public [Pure] 获取当前凝视目标的名字
function InteractComp:GetGazeName()
    return self.GazeName
end

---@public [Pure] 获取当前交互的目标
---@return BP_ChrBase
function InteractComp:GetInteractTarget()
    return self.InteractActor
end

---@private [Gaze] [Client] 注视物体
---@param DeltaTime number
function InteractComp:_Gazing(DeltaTime)
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
    local objTypes = {UE.EObjectTypeQuery.Pawn}
    local result = UE.UKismetSystemLibrary.LineTraceSingleForObjects(self:GetOwner(), cameraLoc,
        cameraLoc + cameraFwd * self.GazeDistanceConst, objTypes,
        false, ignores, UE.EDrawDebugTrace.None,
        hitResult, true, UE.FLinearColor(1, 0, 0),
        UE.FLinearColor(0, 1, 0), 1)
    self:C2S_ReqUpdateGazing(hitResult.HitObjectHandle.Actor)
end

---@private [Gaze] [Server] 客户端请求更新当前注视的物体
---@todo 增加Check
---@param InteractActor AActor
function InteractComp:C2S_ReqUpdateGazing_RPC(InteractActor)
    if self.bInteracting then
        return
    end
    -- log.info('InteractComp:C2S_ReqUpdateGazing', obj_util.dispname(InteractActor))
    self.GazeName = ''
    if obj_util.is_valid(InteractActor) and (self:GetOwner().OwnerChr ~= InteractActor) then
        self.InteractActor = InteractActor
        local role = rolelib.role(self.InteractActor)
        if role then
            self.GazeName = role:RoleName()
        end
    end
end

---@private 判断玩家是否可以和目标交互
---@return boolean
function InteractComp:_CanInteract()
    -- 有效性判断
    local ownerChr = self:GetOwner().OwnerChr
    local targetChr = self:GetInteractTarget()
    local ownerRole = rolelib.role(ownerChr)
    local targetRole = rolelib.role(targetChr)
    if not targetRole then
        return false
    end

    ---@todo
    targetRole.QuestGiver:HasAvailableQuest()
    return true
end

return InteractComp