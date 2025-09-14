
---
---@brief 值守在战术位置
---@author zys
---@data Sun May 18 2025 15:12:41 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LDecorator_DutyTraticPos: LDecorator
---@field ConstDutyDistance number 是否值守在战术位置的距离判定
local LDecorator_DutyTraticPos = class.class 'LDecorator_DutyTraticPos' : extends 'LDecorator' {
--[[private]]
    ConstDutyDistance = nil,
}
function LDecorator_DutyTraticPos:ctor(NodeDispName, DutyDistance)
    class.LDecorator.ctor(self, NodeDispName)
    self.ConstDutyDistance = DutyDistance or 100
end
function LDecorator_DutyTraticPos:Judge()
    if not self.Blackboard then
        return false
    end
    local FightPosLoc = self.Blackboard:GetBBValue(BBKeyDef.FightPosLoc)
    if not FightPosLoc then
        return false
    end
    local OwnerLoc = self.Chr:GetNavAgentLocation()
    local Distance = UE.UKismetMathLibrary.Vector_Distance(OwnerLoc, FightPosLoc)
    if Distance < self.ConstDutyDistance then
        return false
    end
    self.Blackboard:SetBBValue(BBKeyDef, BBKeyDef.MoveTarget)
    return true
end