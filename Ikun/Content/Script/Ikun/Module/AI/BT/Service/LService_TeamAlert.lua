
---
---@brief 通知Team的警戒同步任务
---@author zys
---@data Fri Apr 25 2025 21:21:44 GMT+0800 (中国标准时间)
---

---@class LService_TeamAlert : LService
---@field StaticRange number
local LService_TeamAlert = class.class 'LService_TeamAlert' : extends 'LService' {
    ctor = function()end,
    StaticRange = nil,
}
function LService_TeamAlert:ctor(NodeDispName, TickInterval, Range)
    class.LService.ctor(self, NodeDispName, TickInterval)
    self.StaticRange = Range or 1500
end
function LService_TeamAlert:OnUpdate(DeltaTime)
    class.LService.OnUpdate(self, DeltaTime)

    local bDrawed = false
    if obj_util.is_valid(self.Chr) and self.Chr:GetRole() then
        local Hits = actor_util.find_actors_in_range(self.Chr,self.Chr:K2_GetActorLocation(),
            self.StaticRange, self:MakeFindRangeActorsFilterFn())
        for i = 1, Hits:Length()do
            local Hit = Hits:Get(i)
            if Hit:IsA(UE.ACharacter) then
                if self.Chr:GetRole():IsEnemy(Hit:GetRole()) then
                    local FightTarget = Hit:GetRole().Team or Hit:GetRole()
                    self.Chr:GetRole().Team:Encounter(FightTarget)
                    if not bDrawed then
                        self:DrawRange()
                        bDrawed = true
                    end
                end
                -- log.log('hit actor : ', obj_util.dispname(Hit) , Hit:IsA(UE.ACharacter))
                self:DoTerminate(true)
            end
        end
    end
end
---@private
function LService_TeamAlert:MakeFindRangeActorsFilterFn()
    local FilterEnemy = function(HitActor)
        if not HitActor.GetRole then
            return false
        end
        if not HitActor:GetRole() then
            return false
        end
        if not self.Chr:GetRole():IsEnemy(HitActor:GetRole()) then
            return false
        end
        return true
    end
    return FilterEnemy
end
---@private [Debug]
function LService_TeamAlert:DrawRange()
    local Color = UE.FLinearColor(1, 1, 0)
    local Duration = 2
    UE.UKismetSystemLibrary.DrawDebugSphere(self.Chr, self.Chr:K2_GetActorLocation(), self.StaticRange, 12, Color, Duration, 4)
end