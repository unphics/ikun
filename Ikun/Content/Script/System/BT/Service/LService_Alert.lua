---
---@brief 一个简单的警戒同步任务
---@author zys
---@data Sun Jan 19 2025 20:22:54 GMT+0800 (中国标准时间)
---@todo 更多配置项,在Role中
---

---@class LService_Alert: LService
---@field StaticRange number
local LService_Alert = class.class 'LService_Alert' : extends 'LService' {
    OnUpdate = function()end,
}
function LService_Alert:ctor(NodeDispName, TickInterval, Range)
    class.LService.ctor(self, NodeDispName, TickInterval)
    self.StaticRange = Range or 1500
end
function LService_Alert:OnUpdate(DeltaTime)
    class.LService.OnUpdate(self, DeltaTime)

    if obj_util.is_valid(self.Chr) and self.Chr:GetRole() then
        local Hits = actor_util.find_actors_in_range(self.Chr,self.Chr:K2_GetActorLocation(),
            self.StaticRange, self:MakeFindRangeActorsFilterFn())
        for i = 1, Hits:Length()do
            local Hit = Hits:Get(i)
            if Hit:IsA(UE.ACharacter) then
                if false then -- 这个是单人的
                    log.error('这里需要处理!!!')
                    -- self.Chr:GetRole():AddEnemyChecked(Hit:GetRole())
                    -- self:DrawAlertResult(Hit)
                end
                if true then -- 这个是Team的
                    if self.Chr:GetRole():IsEnemy(Hit:GetRole()) then
                        self.Chr:GetRole().Team:Encounter(Hit:GetRole().Team)
                    end
                end
                -- log.log('hit actor : ', obj_util.dispname(Hit) , Hit:IsA(UE.ACharacter))
                self:DoTerminate(true)
            end
        end
    end
end
---@private
function LService_Alert:MakeFindRangeActorsFilterFn()
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
function LService_Alert:DrawAlertResult(Actor)
    local color = UE.FLinearColor(1, 1, 0)
    local Duration = 2
    UE.UKismetSystemLibrary.DrawDebugSphere(self.Chr, Actor:K2_GetActorLocation(), 40, 12, color, Duration, 4)
    UE.UKismetSystemLibrary.DrawDebugLine(self.Chr, self.Chr:K2_GetActorLocation(), Actor:K2_GetActorLocation(), color, Duration, 4)
end