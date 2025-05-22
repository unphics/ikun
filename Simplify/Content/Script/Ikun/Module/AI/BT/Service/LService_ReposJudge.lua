
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
    if self.FightTarget:IsDead() then
        return
    end
    if actor_util.is_no_obstacles_between(self.FightTarget.Avatar, self.Chr, actor_util.filter_is_firend_4_obstacles(self.Chr)) then
        self:DoTerminate(true)
    end
end