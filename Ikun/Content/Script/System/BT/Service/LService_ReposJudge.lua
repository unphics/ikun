
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
    -- if not debug_util.IsChrDebug(self.Chr) then
    --     self:DoTerminate(true)
    --     return
    -- end
    if not self.FightTarget then
        self.FightTarget = self.Blackboard:GetBBValue(BBKeyDef.FightTarget)
    end
    if self.FightTarget:IsRoleDead() then
        return
    end
    if debug_util.IsChrDebug(self.Chr) then
        local a = 1
    end
    if not actor_util.has_obstacles(self.FightTarget.Avatar, self.Chr, actor_util.filter_is_firend_4_obstacles(self.Chr), function(tb)
            local owner = self.Chr:GetRole()
            for i, chr in ipairs(tb) do
                local role = chr:GetRole() ---@type RoleBaseClass
            end
        end) then
        draw_util.draw_dir_sphere(self.Chr, self.FightTarget.Avatar, draw_util.white)
        self:DoTerminate(true)
    end
end