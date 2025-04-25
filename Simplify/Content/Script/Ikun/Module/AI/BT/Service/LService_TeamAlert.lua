
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
function LService_TeamAlert:ctor(DisplayName, TickInterval, Range)
    class.LService.ctor(self, DisplayName, TickInterval)
    self.StaticRange = Range or 1500
end
function LService_TeamAlert:OnUpdate(DeltaTime)
    class.LService.OnUpdate(self, DeltaTime)

    if obj_util.is_valid(self.Chr) and self.Chr:GetRole() then
        local Hits = actor_util.find_actors_in_range(self.Chr,self.Chr:K2_GetActorLocation(),
            self.StaticRange, self:MakeFindRangeActorsFilterFn())
        for i = 1, Hits:Length()do
            local Hit = Hits:Get(i)
            if Hit:IsA(UE.ACharacter) then
                ---@todo last 该写Team添加敌人了
                if self.Chr:GetRole():IsEnemy(Hit:GetRole()) then
                    self.Chr:GetRole().Team:Encounter(Hit:GetRole().Team)
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