

---
---@brief 移动为了调整站位
---@author zys
---@data Tue May 20 2025 23:00:43 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LTask_Move4Repos : LTask_AiMoveBase
local LTask_Move4Repos = class.class 'LTask_Move4Repos' : extends 'LTask_AiMoveBase' {
}
function LTask_Move4Repos:OnInit()
    class.LTask_AiMoveBase.OnInit(self)
    self.ConstTestInterval = 0.5
    self.TestIntervalCurTimeCount = 0.5

    self.FightTarget = self.Blackboard:GetBBValue(BBKeyDef.FightTarget)
end
function LTask_Move4Repos:OnUpdate(DeltaTime)
    self.TestIntervalCurTimeCount = self.TestIntervalCurTimeCount + DeltaTime
    if self.TestIntervalCurTimeCount > self.ConstTestInterval then
        self.TestIntervalCurTimeCount = self.TestIntervalCurTimeCount - self.ConstTestInterval
        if actor_util.is_no_obstacles_between(self.FightTarget.Avatar, self.Chr, self:MakeFilterFn()) then
            self:DoTerminate(true)
        end
    end
    class.LTask_AiMoveBase.OnUpdate(self, DeltaTime)
end
function LTask_Move4Repos:MakeFilterFn()
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
