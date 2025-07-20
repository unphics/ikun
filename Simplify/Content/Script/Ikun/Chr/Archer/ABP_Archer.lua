
---
---@author  zys
---@data    Sun Jul 20 2025 12:27:04 GMT+0800 (中国标准时间)
---

local VelBlendStruct = UE.UObject.Load('/Game/Ikun/Blueprint/Anim/VelBlend.VelBlend') ---@type FVelBlend

---@class ABP_Archer: ABP_Archer_C
---@field Chr BP_ChrBase
local ABP_Archer = UnLua.Class()

-- function ABP_Archer:Initialize(Initializer)
-- end

-- function ABP_Archer:BlueprintInitializeAnimation()
-- end

---@override
function ABP_Archer:BlueprintBeginPlay()
    if self:TryGetPawnOwner().GetRole then
        self.Chr = self:TryGetPawnOwner()
    end
end

---@override Tick
function ABP_Archer:BlueprintUpdateAnimation(DeltaTimeX)
    if not self.Chr then
        return
    end
    self:UpdateFightInfo()
    self:UpdateMoveSpeed(DeltaTimeX)
end

---@override
-- function ABP_Archer:BlueprintPostEvaluateAnimation()
-- end

---@private 更新有关入战出战的相关信息
function ABP_Archer:UpdateFightInfo()
    self.bInFight = gas_util.asc_has_tag_by_name(self.Chr, 'Role.State.InFight')
end

---@private 更新地面移动有关信息
function ABP_Archer:UpdateMoveSpeed(DeltaTime)
    ---@step 1.计算此时瞬时混合速度
    local worldVel = self.Chr:GetVelocity() -- 这是一个世界空间的速度
    local worldRot = self.Chr:K2_GetActorRotation()
    local worldVelDir = UE.UKismetMathLibrary.Normal(worldVel, 0.1) -- tolerance:公差
    local relVelDir = UE.UKismetMathLibrary.LessLess_VectorRotator(worldVelDir, worldRot) ---@type FVector 将世界空间的速度转成角色本地空间的速度

    local velSumCount = math.abs(relVelDir.X) + math.abs(relVelDir.Y) + math.abs(relVelDir.Z)
    local velDirPer = relVelDir / velSumCount ---@type FVector 归一化的相对速度, 每个值都是百分比占比量

    local velBelnd = VelBlendStruct() ---@type FVelBlend
    velBelnd.F = math_util.clamp(velDirPer.X, 0, 1)
    velBelnd.B = math.abs(math_util.clamp(velDirPer.X, -1, 0))
    velBelnd.L = math.abs(math_util.clamp(velDirPer.Y, -1, 0))
    velBelnd.R = math_util.clamp(velDirPer.Y, 0, 1)

    ---@step 2.将当前混合速度插值到此时的瞬时混合速度

    local interp_speed = 1
    self.VelBlend.F = UE.UKismetMathLibrary.FInterpTo(self.VelBlend.F, velBelnd.F, DeltaTime, interp_speed)
    self.VelBlend.B = UE.UKismetMathLibrary.FInterpTo(self.VelBlend.B, velBelnd.B, DeltaTime, interp_speed)
    self.VelBlend.L = UE.UKismetMathLibrary.FInterpTo(self.VelBlend.L, velBelnd.L, DeltaTime, interp_speed)
    self.VelBlend.R = UE.UKismetMathLibrary.FInterpTo(self.VelBlend.R, velBelnd.R, DeltaTime, interp_speed)
    
    -- log.dev(log.key.abp, 'relVelDir', relVelDir)
    -- log.dev(log.key.abp, 'velDirPer', velDirPer)
end

return ABP_Archer