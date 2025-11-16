
---
---@brief 找一个适合释放技能的位置
---@author zys
---@data Mon May 19 2025 23:26:06 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")
local NavMoveData = require('Ikun/Module/Nav/NavMoveData')
local NavMoveData = require('Ikun/Module/Nav/NavMoveData')

---@class LTask_FindLoc4Ability : LTask
local LTask_FindLoc4Ability = class.class 'LTask_FindLoc4Ability' : extends 'LTask' {
    ctor = function()end,
}
function LTask_FindLoc4Ability:ctor(NodeDispName)
    class.LTask.ctor(self, NodeDispName)
end

function LTask_FindLoc4Ability:OnInit()
    class.LTask.OnInit(self)
    local Loc = self:FindReposLoc_TwoSideRound() -- self:FindReposLoc_Circle()
    -- local bSuccess, To = NavMoveData.RandomNavPointInRadius(self.Chr, Loc, 150)
    if Loc then
        self.Blackboard:SetBBValue(BBKeyDef.MoveTarget, Loc)
    else
        log.dev('LTask_FindLoc4Ability:OnInit() 没有移动点')
    end
end
function LTask_FindLoc4Ability:OnUpdate(DeltaTime)
    self:DoTerminate(true)
end
function LTask_FindLoc4Ability:GetTargetActor()
    local FightTarget = self.Blackboard:GetBBValue(BBKeyDef.FightTarget)
    if class.instanceof(FightTarget, class.RoleBaseClass) then
        return FightTarget.Avatar
    end
    if FightTarget.IsA then
        return FightTarget
    end
end
---@private [Circle]
function LTask_FindLoc4Ability:FindReposLoc_Circle()
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
            if debug_util.IsChrDebug(self.Chr) then
                draw_util.draw_dir_sphere(OwnerChr, newPos)
            end
            if not actor_util.has_obstacles(newPos, TargetLoc, actor_util.filter_is_firend_4_obstacles(self.Chr)) then
                if debug_util.IsChrDebug(self.Chr) then
                    draw_util.draw_dir_sphere(newPos, TargetLoc, draw_util.green)
                end
                return newPos
            end
            Dir = Dir * -1
        end
        CurAngle = CurAngle + StepAngle
    end
end
function LTask_FindLoc4Ability:FindReposLoc_TwoSideRound()
    local OwnerLoc = self.Chr:GetNavAgentLocation()
    local Radius = 300
    local TargetLoc = self:GetTargetActor():GetNavAgentLocation()
    local Owner2Target = OwnerLoc - TargetLoc
    local Dir = Owner2Target -- UE.FVector(Owner2Target)
    Dir:Normalize()
    Dir = Dir * Radius
    local Rot1 = UE.FRotator(0, 90, 0)
    local Rot2 = UE.FRotator(0, -90, 0)
    local Dir1 = Rot1:RotateVector(Dir)
    local Dir2 = Rot2:RotateVector(Dir)
    local Center1 = OwnerLoc + Dir1 -- OwnerLoc + Dir + Dir1
    local Center2 = OwnerLoc + Dir2 -- OwnerLoc + Dir + Dir2
    local Point = (math.random() > 0.5) and Center1 or Center2
    draw_util.draw_sphere(Point, Radius)
    local bSuccess, ProjectPoint = NavMoveData.ProjectPointToNavMesh(self.Chr, Point, UE.FVector(300, 300, 300))
    return ProjectPoint
end