
---
---@brief 判断需要调整战术位置
---@author zys
---@data Sun May 18 2025 15:12:41 GMT+0800 (中国标准时间)
---@todo 暂时把判断和判断后的新位置的计算写在一起
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LDecorator_Repos4Ability: LDecorator
local LDecorator_Repos4Ability = class.class 'LDecorator_Repos4Ability' : extends 'LDecorator' {
--[[private]]
}
function LDecorator_Repos4Ability:ctor(DisplayName)
    class.LDecorator.ctor(self, DisplayName)
end
function LDecorator_Repos4Ability:Judge()
    local FightTargetActor = self:GetTargetActor()
    if not FightTargetActor then
        return false
    end
    local bNoObs = actor_util.is_no_obstacles_between(self.Chr, FightTargetActor)
    if bNoObs then
        return false
    end
    local NewLoc = self:FindRepos()
    self:DrawTargetLoc(NewLoc)
    self.Blackboard:SetBBValue(BBKeyDef.MoveTarget, NewLoc)
    return true
end
---@private
function LDecorator_Repos4Ability:GetTargetActor()
    local FightTarget = self.Blackboard:GetBBValue(BBKeyDef.FightTarget)
    if class.instanceof(FightTarget, class.RoleClass) then
        return FightTarget.Avatar
    end
    if FightTarget.IsA then
        return FightTarget
    end
    local a = 1
end
function LDecorator_Repos4Ability:FindRepos()
    local StepArcLen = 50 -- 每步圆弧长度
    local MaxAngle = 60   -- 最大偏转角度（从正前方向左右偏）
    local StepAngle = 5   -- 每步转角（度）
    
    local Chr = self.Chr
    local Target = self:GetTargetActor()
    if not Chr or not Target then return nil end

    local OwnerLoc = Chr:K2_GetActorLocation()
    local TargetLoc = Target:K2_GetActorLocation()

    local Radius = UE.UKismetMathLibrary.Vector_Distance(OwnerLoc, TargetLoc)
    local BaseDir = TargetLoc - OwnerLoc
    BaseDir:Normalize()

    -- 起始角度从 StepAngle 开始，跳过正中方向（可能被阻挡）
    for angle = StepAngle, MaxAngle, StepAngle do
        for _, dirMul in ipairs({1, -1}) do  -- 顺时针、逆时针
            local actualAngle = angle * dirMul
            local rot = UE.FRotator(0, actualAngle, 0)
            local rotatedDir = rot:RotateVector(BaseDir)
            local candidatePos = OwnerLoc + rotatedDir * Radius

            if actor_util.is_no_obstacles_between(Chr, candidatePos) and
               actor_util.is_no_obstacles_between(Target, candidatePos) then
                return candidatePos
            end
        end
    end

    -- 若没找到合适站位，返回 nil 或当前位置
    return nil
end
-- function LDecorator_Repos4Ability:FindRepos()
--     local StepLen = 50
--     local Radius = UE.UKismetMathLibrary.Vector_Distance(self:GetTargetActor():K2_GetActorLocation(), self.Chr:K2_GetActorLocation())
--     local StepAngle = 5 -- 360 / (2 * math.pi * Radius / StepLen)
--     local OwnerLoc = self.Chr:K2_GetActorLocation()
--     local TargetLoc = self:GetTargetActor():K2_GetActorLocation()
--     local MaxAngle = 60
--     local BaseDir = TargetLoc - OwnerLoc
--     BaseDir:Normalize()
--     local CurAngle = 0
--     local Dir = 1 -- 1=左, -1=右

--     while CurAngle < MaxAngle do
--         for i = 1, 2 do -- 左右
--             local angle = CurAngle * Dir
--             local rot = UE.FRotator(0, angle, 0) ---@type FRotator
--             local newDir = rot:RotateVector(BaseDir)
--             local newPos = OwnerLoc + newDir * Radius
--             if actor_util.is_no_obstacles_between(self:GetTargetActor(), newPos) then
--                 return newPos
--             end
--             Dir = Dir * -1
--         end
--         CurAngle = CurAngle + StepAngle
--     end
-- end

function LDecorator_Repos4Ability:DrawTargetLoc(loc)
    local Color = UE.FLinearColor(1, 0, 0)
    local Duration = 2
    UE.UKismetSystemLibrary.DrawDebugSphere(self.Chr, loc, 40, 12, Color, Duration, 2)
    UE.UKismetSystemLibrary.DrawDebugLine(self.Chr, self.Chr:K2_GetActorLocation(), loc, Color, Duration, 2)
end