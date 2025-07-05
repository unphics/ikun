
---
---@brief   寻找安全区
---@author  zys
---@data    Tue Jul 01 2025 10:46:05 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LTask_FindSafeArea: LTask
local LTask_FindSafeArea = class.class 'LTask_FindSafeArea' : extends 'LTask' {
--[[public]]
    ctor = function()end,
    OnInit = function()end,
}

function LTask_FindSafeArea:ctor(NodeDispName)
    class.LTask.ctor(self, NodeDispName)
end

function LTask_FindSafeArea:OnInit()
    class.LTask.OnInit(self)

    local OwnerAgent = self.Chr:GetNavAgentLocation()
    local Team = self.Chr:GetRole().Team
    local TeamCenter = Team.TeamMove:CalcTeamMemberCenter(Team.TeamMember:GetAllMember())
    local EnemyCenter = Team.TeamMove:CalcTeamMemberCenter(Team.TeamEnemy:GetAllEnemy())
    local Distance = UE.UKismetMathLibrary.Vector_Distance(TeamCenter, OwnerAgent)
    if Distance > 200 then
        local BackDir = TeamCenter - EnemyCenter
        BackDir:Normalize()
        BackDir = BackDir * 200
        local bSuccess, ResultLoc = class.NavMoveData.RandomNavPointInRadius(self.Chr, TeamCenter + BackDir, 150)
        if bSuccess then
            -- if debug_util.IsChrDebug(self.Chr) then
                draw_util.draw_dir_sphere(self.Chr, ResultLoc, draw_util.blue)
            -- end
            self.Blackboard:SetBBValue(BBKeyDef.SafeLoc, ResultLoc)
        else
            self.Blackboard:SetBBValue(BBKeyDef.SafeLoc, TeamCenter)
        end
    end
end

function LTask_FindSafeArea:OnUpdate(DeltaTime)
    self:DoTerminate(true)
end

return LTask_FindSafeArea