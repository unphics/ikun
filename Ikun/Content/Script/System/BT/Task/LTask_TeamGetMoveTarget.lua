

---
---@brief 获取自己的移动目标
---@author zys
---@data Thu Apr 24 2025 22:01:39 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LTask_TeamGetMoveTarget : LTask
local LTask_TeamGetMoveTarget = class.class 'LTask_TeamGetMoveTarget' : extends 'LTask' {
    ctor = function()end,
}
function LTask_TeamGetMoveTarget:ctor(NodeDispName)
    class.LTask.ctor(self, NodeDispName)
end
function LTask_TeamGetMoveTarget:OnInit()
    class.LTask.OnInit(self)

    local Team = self.Chr:GetRole().Team
    if not Team then
        return log.error('LTask_TeamGetMoveTarget:OnInit() 该角色没有Team')
    end
    local MoveTarget = Team.TeamMove:GetMoveTarget(self.Chr:GetRole())
    self.Blackboard:SetBBValue(BBKeyDef.MoveTarget, MoveTarget)
    self:DrawTargetLoc(MoveTarget)
end
function LTask_TeamGetMoveTarget:OnUpdate(DeltaTime)
    self:DoTerminate(true)
end
function LTask_TeamGetMoveTarget:DrawTargetLoc(MoveTarget)
    if not MoveTarget then
        return
    end
    local color = UE.FLinearColor(1, 0, 0)
    local Duration = 2
    UE.UKismetSystemLibrary.DrawDebugSphere(self.Chr, MoveTarget, 40, 12, color, Duration, 2)
    UE.UKismetSystemLibrary.DrawDebugLine(self.Chr, self.Chr:K2_GetActorLocation(), MoveTarget, color, Duration, 2)
end
return LTask_TeamGetMoveTarget