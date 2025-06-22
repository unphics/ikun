
---
---@brief   判断当前是此种行为
---@author  zys
---@data    Wed Jun 18 2025 22:20:22 GMT+0800 (中国标准时间)
---

local BehavDef = require("Ikun.Module.AI.BT.Behav.BehavDef")
local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")
local ELStatus = require('Ikun/Module/AI/BT/ELStatus')

---@class LDecorator_IsBehav : LDecorator
---@field CondBehavKey BehavDef
local LDecorator_IsBehav = class.class 'LDecorator_IsBehav' : extends 'LDecorator' {
--[[public]]
    ctor = function()end,
    Judge = function()end,
    PrintNode = function()end,
--[[private]]
    CondBehavKey = nil,
}
---@override
function LDecorator_IsBehav:ctor(NodeDispName, CondBehavKey)
    class.LDecorator.ctor(self, NodeDispName)
    self.CondBehavKey = CondBehavKey
end
---@override
function LDecorator_IsBehav:Judge()
    local CurBehavKey = self.Blackboard:GetBBValue(BBKeyDef.CurBehav)
    if not CurBehavKey then
        return false
    end
    return CurBehavKey == self.CondBehavKey
end
---@override
function LDecorator_IsBehav:PrintNode(nDeep)
    local Text = ''
    if nDeep > 0 then
        for i = 1, nDeep do
            Text = Text .. '        '
        end
    end
    Text = Text .. string.format('Decorator : %s [%s] : %s\n',self.NodeDispName, self.CondBehavKey, ELStatus.PrintLStatus(self.LastStatus))
    Text = Text .. self.Child:PrintNode(nDeep)
    return Text
end
