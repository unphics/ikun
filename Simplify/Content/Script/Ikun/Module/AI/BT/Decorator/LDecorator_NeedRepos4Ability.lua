
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
function LDecorator_NeedRepos4Ability:ctor(DisplayName)
    class.LDecorator.ctor(self, DisplayName)
end
function LDecorator_NeedRepos4Ability:Judge()
    local FightTargetActor = self:GetTargetActor()
    if not FightTargetActor then
        return false
    end
    local bNoObs = actor_util.is_no_obstacles_between(self.Chr, FightTargetActor, self:MakeFilterFn())
    if bNoObs then
        return false
    end
    return true
end
---@private
function LDecorator_NeedRepos4Ability:GetTargetActor()
    local FightTarget = self.Blackboard:GetBBValue(BBKeyDef.FightTarget)
    if class.instanceof(FightTarget, class.RoleClass) then
        return FightTarget.Avatar
    end
    if FightTarget.IsA then
        return FightTarget
    end
end
function LDecorator_NeedRepos4Ability:MakeFilterFn()
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
