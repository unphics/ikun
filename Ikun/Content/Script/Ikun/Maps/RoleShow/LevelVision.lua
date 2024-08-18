--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class LevelVision
local LevelVision = UnLua.Class()
LevelVision.BlendPPTime = 0.7
LevelVision.VisionTransitionAlpha = 1

---`public` [SwitchLevel] [Client]
LevelVision.PlaySeq = function(self) end
---`private`
local BlendPostProcess = function(self, DeltaTime) end
---`private` [SwitchLevel] [Client]
local InitEnv = function(self) end

-- function LevelVision:Initialize(Initializer)
-- end

-- function LevelVision:UserConstructionScript()
-- end

function LevelVision:ReceiveBeginPlay()
    InitEnv(self)
end

-- function LevelVision:ReceiveEndPlay()
-- end

function LevelVision:ReceiveTick(DeltaSeconds)
    -- notice: 这玩意在客户端生成的
    -- if self:HasAuthority() then
    --     return
    -- end
    BlendPostProcess(self, DeltaSeconds)
end

-- function LevelVision:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function LevelVision:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function LevelVision:ReceiveActorEndOverlap(OtherActor)
-- end

function LevelVision:PlaySeq()
    log.error("level vison play seq")

    local CameraManager = UE.UGameplayStatics.GetPlayerCameraManager(self, 0)
    -- self.SceneCaptureComponent2D:K2_SetWorldLocationAndRotation(CameraManager:GetCameraLocation(), CameraManager:GetCameraRotation(), false, UE.FHitResult, true)
    self.SceneCaptureComponent2D.FOVAngle = CameraManager:GetFOVAngle()
    self.SceneCaptureComponent2D:CaptureScene()
    self.PostProcess.bEnabled = true
    self.VisionTransitionAlpha = self.BlendPPTime

    self:AAA()
end

InitEnv = function(self)
    log.error("level vision init env")
    local Mat = UE.UObject.Load('/Game/Ikun/Maps/RoleShow/M_RoleShow.M_RoleShow')
    self.BlendCameraMat = UE.UKismetMaterialLibrary.CreateDynamicMaterialInstance(self, Mat)

    self.BlendCameraMat:SetTextureParameterValue('Tex', self.SceneCaptureComponent2D.TextureTarget)
    self:SetPPSettingFromMat(self.BlendCameraMat, self.PostProcess)
    self.PostProcess.bEnabled = false
end

BlendPostProcess = function(self, DeltaTime)
    local Diff = (self.BlendPPTime - self.VisionTransitionAlpha) * 1.3
    if Diff < 5 then
        self.BlendCameraMat:SetScalarParameterValue('Density', Diff)
        self.BlendCameraMat:SetScalarParameterValue('BlurRadius', (self.BlendPPTime - self.VisionTransitionAlpha) * 1.2)
        -- self.BlendCameraMat:SetScalarParameterValue('Density', 0)
        -- self.BlendCameraMat:SetScalarParameterValue('BlurRadius', 0)
        self.VisionTransitionAlpha = self.VisionTransitionAlpha - DeltaTime
    else
        self.PostProcess.bEnabled = false
    end
end

return LevelVision