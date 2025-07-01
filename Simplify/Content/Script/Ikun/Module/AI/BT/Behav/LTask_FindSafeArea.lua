
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
    local Distance = UE.UKismetMathLibrary.Vector_Distance(TeamCenter, OwnerAgent)
    if Distance < 400 then
        local BackLoc = TeamCenter - OwnerAgent
        BackLoc:Normalize()
        BackLoc = BackLoc * 200
        local bSuccess, ResultLoc = class.NavMoveData.RandomNavPointInRadius(self.Chr, BackLoc, 400)
        if bSuccess then
            self.Blackboard:SetBBValue(BBKeyDef.SafeLoc, ResultLoc)
        else
            self.Blackboard:SetBBValue(BBKeyDef.SafeLoc, nil)
        end
    end
end

function LTask_FindSafeArea:OnUpdate(DeltaTime)
    self:DoTerminate(true)
end

return LTask_FindSafeArea