
local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LTask_RandNavTarget: LTask
---@field StaticNearestDist number
---@field StaticFarestDist number
---@field StaticMaxIterCount number
---@field ResultLoc FVector
local LTask_RandNavTarget = class.class 'LTask_RandNavTarget' : extends 'LTask' {
    ctor = function() end,
}
function LTask_RandNavTarget:ctor(NodeDispName, NearestDist, FarestDist, MaxIterCount)
    class.LTask.ctor(self, NodeDispName)
    self.StaticNearestDist = NearestDist
    self.StaticFarestDist = FarestDist
    self.StaticMaxIterCount = MaxIterCount or 10
    self.ResultLoc = nil
end
function LTask_RandNavTarget:OnInit()
    class.LTask.OnInit(self)
    local AgentLoc = self.Chr:GetNavAgentLocation()
    local FarestLoc = nil
    local FarestDist = nil
    local IterCount = 0
    while true do
        IterCount = IterCount + 1
        local RandLoc = UE.FVector(0, 0, 0)
        local bSuccess = UE.UNavigationSystemV1.K2_GetRandomReachablePointInRadius(self.Chr, AgentLoc, RandLoc, self.StaticFarestDist, nil, nil)
        if not bSuccess then
            log.error('LTask_RandNavTarget:OnInit: Failed to find reachable point in radius !')
            return
        end
        local Dist = UE.UKismetMathLibrary.Vector_Distance(AgentLoc, RandLoc)
        if Dist > self.StaticNearestDist then
            self.ResultLoc = RandLoc
            return
        end
        if not FarestLoc then
            FarestLoc = RandLoc
            FarestDist = Dist
        end
        if Dist > FarestDist then
            FarestLoc = RandLoc
            FarestDist = Dist
        end
        if IterCount > self.StaticMaxIterCount then
            self.ResultLoc = RandLoc
            return
        end
    end
end
function LTask_RandNavTarget:OnUpdate(DeltaTime)
    self.Blackboard:SetBBValue(BBKeyDef.MoveTarget, self.ResultLoc)
    if self.ResultLoc then
        self:DrawTargetLoc()
    end
    self:DoTerminate(self.ResultLoc and true or false)
end

function LTask_RandNavTarget:DrawTargetLoc()
    local Color = UE.FLinearColor(1, 0, 0)
    local Duration = 2
    UE.UKismetSystemLibrary.DrawDebugSphere(self.Chr, self.ResultLoc, 40, 12, Color, Duration, 2)
    UE.UKismetSystemLibrary.DrawDebugLine(self.Chr, self.Chr:K2_GetActorLocation(), self.ResultLoc, Color, Duration, 2)
end