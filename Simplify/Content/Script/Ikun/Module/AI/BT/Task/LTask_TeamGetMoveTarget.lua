
---
---@brief 获取自己的移动目标
---@author zys
---@data Thu Apr 24 2025 22:01:39 GMT+0800 (中国标准时间)
---

---@class LTask_TeamGetMoveTarget : LTask
local LTask_TeamGetMoveTarget = class.class 'LTask_TeamGetMoveTarget' : extends 'LTask' {
    ctor = function()end,
}
function LTask_TeamGetMoveTarget:ctor(DisplayName)
    class.LTask.ctor(self, DisplayName)
end
function LTask_TeamGetMoveTarget:OnInit()
    class.LTask.OnInit(self)

    local Team = self.Chr:GetRole().Team
    if not Team then
        return log.error('LTask_TeamGetMoveTarget:OnInit() 该角色没有Team')
    end
    local MoveTarget = Team.TeamMove:GetMoveTarget(self.Chr:GetRole())
    self.Blackboard:SetBBValue('MoveTarget', MoveTarget)
end
function LTask_TeamGetMoveTarget:OnUpdate(DeltaTime)
    self:DoTerminate(true)
end
return LTask_TeamGetMoveTarget