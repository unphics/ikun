
---
---@brief 判断需要调整战术位置
---@author zys
---@data Sun May 18 2025 15:12:41 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LDecorator_NeedRepos4Ability: LDecorator
local LDecorator_NeedRepos4Ability = class.class 'LDecorator_NeedRepos4Ability' : extends 'LDecorator' {
--[[private]]
}
function LDecorator_NeedRepos4Ability:ctor(NodeDispName)
    class.LDecorator.ctor(self, NodeDispName)
end
function LDecorator_NeedRepos4Ability:Judge()
    local FightTargetActor = self:GetTargetActor()
    if not FightTargetActor then
        return false
    end
    -- draw_util.draw_dir_sphere(self.Chr, FightTargetActor, draw_util.white)
    local hasObs = actor_util.has_obstacles_box(self.Chr, FightTargetActor, nil,
        actor_util.filter_is_firend_4_obstacles(self.Chr))
    if not hasObs then
        log.debug(log.key.repos..rolelib.roleid(self.Chr)..'LDecorator_NeedRepos4Ability : 没阻挡！')
        return false
    end
    log.debug(log.key.repos..rolelib.roleid(self.Chr)..'LDecorator_NeedRepos4Ability : 阻挡！！！')
    return true
end
---@private
function LDecorator_NeedRepos4Ability:GetTargetActor()
    local FightTarget = self.Blackboard:GetBBValue(BBKeyDef.FightTarget)
    if class.instanceof(FightTarget, class.RoleBaseClass) then
        return FightTarget.Avatar
    end
    if FightTarget.IsA then
        return FightTarget
    end
end
