
---
---@brief   等待移动到
---@author  zys
---@data    Wed Jun 18 2025 23:39:53 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LTask_WaitMoveArrived : LTask
---@field ConstMoveTargetBBKey BBKeyDef
local LTask_WaitMoveArrived = class.class 'LTask_WaitMoveArrived' : extends 'LTask' {
--[[public]]
    ctor = function()end,
    OnInit = function()end,
    OnUpdate = function()end,
--[[private]]
    MoveSuceesss = function()end,
    MoveFailed = function()end,
    ConstMoveTargetBBKey = nil,
}
function LTask_WaitMoveArrived:ctor(NodeDispName, ConstMoveTargetBBKey)
    class.LTask.ctor(self, NodeDispName)
    self.ConstMoveTargetBBKey = ConstMoveTargetBBKey
end
function LTask_WaitMoveArrived:OnInit()
    local MoveBehavObj = self.Blackboard:GetBBValue(BBKeyDef.MoveBehavObj) ---@type NavMoveBehav
    local MoveTarget = self.Blackboard:GetBBValue(self.ConstMoveTargetBBKey)
    -- if self.ConstMoveTargetBBKey == BBKeyDef.SafeLoc then
    --     log.dev('寻路安全区', MoveTarget)
    -- end
    if MoveBehavObj and MoveTarget then
        local tb = {} ---@type NavMoveBehavCallbackInfo
        tb.This = self
        tb.OnNavMoveArrived = self.MoveSuceesss
        tb.OnNavMoveCancelled = self.MoveFailed
        tb.OnNavMoveLostTarget = self.MoveFailed
        tb.OnNavMoveStuck = self.MoveFailed
        MoveBehavObj:NewMoveToTask(MoveTarget, 50, tb)
    end
end
function LTask_WaitMoveArrived:OnUpdate(DeltaTime)
end

function LTask_WaitMoveArrived:MoveSuceesss()
    -- log.debug('LTask_WaitMoveArrived:MoveSuceesss()', rolelib.roleid(self.Chr))
    self:DoTerminate(true)
end
function LTask_WaitMoveArrived:MoveFailed()
    -- log.debug('LTask_WaitMoveArrived:MoveFailed()', rolelib.roleid(self.Chr))
    self:DoTerminate(false)
end