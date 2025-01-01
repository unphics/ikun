
---@class LService_Alert: LService
---@field StaticRange number
local LService_Alert = class.class 'LService_Alert' : extends 'LService' {
    OnUpdate = function()end,
}
function LService_Alert:ctor(DisplayName, TickInterval, Range)
    class.LService.ctor(self, DisplayName, TickInterval)
    self.StaticRange = Range or 1500
end
function LService_Alert:OnUpdate(DeltaTime)
    class.LService.OnUpdate(self, DeltaTime)

    if obj_util.is_valid(self.Chr) then
        local Hits = actor_util.find_actors_in_range(self.Chr,self.Chr:K2_GetActorLocation(), self.StaticRange)
        -- log.dev("hits", Hits:Length())
        for i = 1, Hits:Length()do
            local Hit = Hits:Get(i)
            if Hit:IsA(UE.ACharacter) then
                if Hit:GetRole() and self.Chr:GetRole() and self.Chr:GetRole():AddEnemyChecked(Hit:GetRole()) then
                    -- log.dev('hit actor : ', obj_util.display_name(Hit) , Hit:IsA(UE.ACharacter))
                    self:DoTerminate(true)
                    return
                end
            end
        end
    end
end