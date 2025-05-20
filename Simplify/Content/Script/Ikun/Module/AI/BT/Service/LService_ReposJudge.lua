
local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LService_ReposJudge: LService
local LService_ReposJudge = class.class 'LService_ReposJudge' : extends 'LService' {
    OnUpdate = function()end,
}
function LService_ReposJudge:OnInit()
    class.LService.OnInit(self)
    self.CurTickCount = self.StaticTickInterval
end
function LService_ReposJudge:OnUpdate(DeltaTime)
    if not self.FightTarget then
        self.FightTarget = self.Blackboard:GetBBValue(BBKeyDef.FightTarget)
    end
    if actor_util.is_no_obstacles_between(self.FightTarget.Avatar, self.Chr, self:MakeFilterFn()) then
        self:DoTerminate(true)
    end
end
function LService_ReposJudge:MakeFilterFn()
    local FilterEnemy = function(HitActor)
        if not HitActor.GetRole then
            return true
        end
        local role = HitActor:GetRole()
        if not role then
            return true
        end
        local owner = self.Chr:GetRole()
        if owner:IsFirend(role) then
            -- log.dev('line trace =================== firend', owner, owner:GetDisplayName(), role:GetDisplayName())
            return true
        end
        -- log.dev('line trace =================== enemy', owner, owner:GetDisplayName(), role:GetDisplayName())
        return false
    end
    return FilterEnemy
end