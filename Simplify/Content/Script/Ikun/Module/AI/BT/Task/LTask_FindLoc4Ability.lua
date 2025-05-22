
---
---@brief 找一个适合释放技能的位置
---@author zys
---@data Mon May 19 2025 23:26:06 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")
local NavMoveData = require('Ikun/Module/Nav/NavMoveData')

---@class LTask_FindLoc4Ability : LTask
local LTask_FindLoc4Ability = class.class 'LTask_FindLoc4Ability' : extends 'LTask' {
    ctor = function()end,
}
function LTask_FindLoc4Ability:ctor(DisplayName)
    class.LTask.ctor(self, DisplayName)
end

function LTask_FindLoc4Ability:OnInit()
    class.LTask.OnInit(self)
    local Loc =  self:FindReposLocWithCircle()
    local To = NavMoveData.RandomNavPointInRadius(self.Chr, Loc, 150)
    self.Blackboard:SetBBValue(BBKeyDef.MoveTarget, To)
end
function LTask_FindLoc4Ability:OnUpdate(DeltaTime)
    self:DoTerminate(true)
end
function LTask_FindLoc4Ability:GetTargetActor()
    local FightTarget = self.Blackboard:GetBBValue(BBKeyDef.FightTarget)
    if class.instanceof(FightTarget, class.RoleClass) then
        return FightTarget.Avatar
    end
    if FightTarget.IsA then
        return FightTarget
    end
end
---@private [Circle]
function LTask_FindLoc4Ability:FindReposLocWithCircle()
    local MaxAngle = 60
    local StepAngle = 5
    local OwnerChr = self.Chr
    local TargetChr = self:GetTargetActor()
    local OwnerLoc = OwnerChr:K2_GetActorLocation()
    local TargetLoc = TargetChr:K2_GetActorLocation()
    local Radius = UE.UKismetMathLibrary.Vector_Distance(OwnerLoc, TargetLoc)

    local BaseDir = OwnerLoc - TargetLoc
    BaseDir:Normalize()

    local CurAngle = 5
    local Dir = (math.random() > 0.5) and 1 or -1

    while CurAngle < MaxAngle do
        for i = 1, 2 do
            local angle = CurAngle * Dir
            local rot = UE.FRotator(0, angle, 0)
            local newDir = rot:RotateVector(BaseDir)
            local newPos = TargetLoc + newDir * Radius
            draw_util.draw_dir_sphere(OwnerChr, newPos)
            if actor_util.is_no_obstacles_between(newPos, TargetLoc, actor_util.filter_is_firend_4_obstacles(self.Chr)) then
                draw_util.draw_dir_sphere(newPos, TargetLoc, draw_util.green)
                return newPos
            end
            Dir = Dir * -1
        end
        CurAngle = CurAngle + StepAngle
    end
end