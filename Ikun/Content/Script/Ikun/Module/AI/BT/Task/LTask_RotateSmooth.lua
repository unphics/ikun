
---@class LTask_RotateSmooth: LTask
---@field StaticRotSpeed number
---@field StaticRotTime number
local LTask_RotateSmooth = class.class 'LTask_RotateSmooth' : extends 'LTask' {
    ctor = function()end,
}
function LTask_RotateSmooth:ctor(DisplayName, RotTime, RotSpeed)
    class.LTask.ctor(self, DisplayName)
    self.StaticRotTime = RotTime or -1
    self.StaticRotSpeed = RotSpeed or -1

end
function LTask_RotateSmooth:OnInit()
    class.LTask.OnInit(self)

    self.TimeCount = 0
    self.TargetRot = nil
    self.DeltaRot = nil

    self.InitRot = self.Chr:K2_GetActorRotation() ---@type FRotator
    local TargetLoc = self.Chr:GetRole().BB.MoveTarget
    if not TargetLoc then
        log.error('LTask_RotateSmooth:OnInit Failed to index TargetLoc !')
        return
    end
    local AgentLoc = self.Chr:GetNavAgentLocation()
    local DirLoc = TargetLoc - AgentLoc
    self.TargetRot = UE.UKismetMathLibrary.Conv_VectorToRotator(DirLoc)
    self.DeltaRot = UE.UKismetMathLibrary.NormalizedDeltaRotator(self.TargetRot, self.InitRot)
    
end
function LTask_RotateSmooth:OnUpdate(DeltaTime)
    if not self.TargetRot then
        self:DoTerminate(false)
        return
    end
    if self.StaticRotTime then
        self.TimeCount = self.TimeCount + DeltaTime    
        local Rate = self.TimeCount / self.StaticRotTime
        local CurRot = UE.FRotator(self.InitRot.Pitch, (self.TargetRot.Yaw - self.InitRot.Yaw) * Rate, self.InitRot.Roll)
        self.Chr:K2_SetActorRotation(CurRot, true)
        if Rate > 1 then
            self:DoTerminate(true)
        end
    end
end