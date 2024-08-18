--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local LevelStatusDef = {
    Closed  = 1,
    Closing = 2,
    Opened  = 3,
    Opening = 4,
}

---@class RoleShowComp
local RoleShowComp = UnLua.Class()

---`public` [SwitchLevel] [Client] 切换3d场景和世界场景
RoleShowComp.DoSwitchLevel = function(self) end
---`public` [SwitchLevel] [Client] 清理资源
RoleShowComp.FreeResources = function(self) end
---`private` [SwitchLevel] [Client] 初始化场景切换数据信息
local InitLevelSwitchInfo = function(self) end
---`temp` 实验render target
local RenderTargetTest = function(self) end

-- function RoleShowComp:Initialize(Initializer)
-- end

function RoleShowComp:ReceiveBeginPlay()
    InitLevelSwitchInfo(self)
end

-- function RoleShowComp:ReceiveEndPlay()
-- end

-- function RoleShowComp:ReceiveTick(DeltaSeconds)
-- end

function RoleShowComp:DoSwitchLevel()
    if self:GetOwner():HasAuthority() then
        log.error("RoleShowComp:DoSwitchLevel : 怎么跑在服务端了?")
        return
    end
    log.error("DoSwitchLevel 111")
    
    if self.LevelStatus == LevelStatusDef.Closed then
        -- async_util.delay(self, 0.2, function()
        -- end)
        self.LevelStatus = LevelStatusDef.Opening
        local EntryLevelName = 'RoleShowLevel'

        local PlayerChr = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
        local Loc = PlayerChr:K2_GetActorLocation()
        Loc.Z = math.max(Loc.Z + 100000, 0) -- zys mark 没懂, 回来再看看
        local Rot = UE.FRotator(0, UE.UGameplayStatics.GetPlayerCameraManager(self, 0).Yaw, 0)
        
        if self.StreamLevel then
            self.StreamLevel:SetShouldBeVisible(true)
        else -- 第一次创建场景
            local bSucceed = false -- todo 这玩意有问题, 回头再看看为啥
            local level = UE.ULevelStreamingDynamic.LoadLevelInstance(self, EntryLevelName, Loc, Rot, bSucceed)
            if level then
                self.StreamLevel = level
                self.StreamLevel.OnLevelShown:Add(self, function()
                    -- on entry level show
                    log.error("step : 场景加载完成")
                    self.LevelStatus = LevelStatusDef.Opened
                    if self.LevelVision then
                        self.LevelVision:PlaySeq()
                    end
                end)
                self.StreamLevel.OnLevelHidden:Add(self, function()
                    self.LevelStatus = LevelStatusDef.Closed
                end)
            end
            RenderTargetTest(self)
        end
    elseif self.LevelStatus == LevelStatusDef.Opened then
        log.error('step : 隐藏场景')
        self.StreamLevel:SetShouldBeVisible(false)
        local BlendFunc = 0
        UE.UGameplayStatics.GetPlayerController(self, 0):SetViewTargetWithBlend(UE.UGameplayStatics.GetPlayerCharacter(self, 0), 0, BlendFunc, 0, false)
    end
end

function RoleShowComp:FreeResources()
    self.StreamLevel:SetIsRequestingUnloadAndRemoval(true)
    self.StreamLevel = nil
end

InitLevelSwitchInfo = function(self)
    if self:GetOwner():HasAuthority() then
        return
    end
    self.LevelStatus = LevelStatusDef.Closed
    log.error('zys init', self.LevelStatus)
end

RenderTargetTest = function(self)
    local SpawnParams = UE.FSpawnParamters()
    SpawnParams.CollisionHandling = UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn
    SpawnParams.Instigator = self:Cast(UE.APawn)
    local SpawnClass = UE.UClass.Load('/Game/Ikun/Maps/RoleShow/BP_LevelVision.BP_LevelVision_C')
    local Transform = self:GetOwner():GetTransform()
    local AlwaysSpawn = UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn
    self.LevelVision = self:GetOwner():GetWorld():SpawnActor(SpawnClass, Transform, AlwaysSpawn, self, self, "")
end

return RoleShowComp
