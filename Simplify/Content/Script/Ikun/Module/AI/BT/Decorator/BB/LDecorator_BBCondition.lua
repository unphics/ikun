
---
---@brief 黑板Condition
---@author zys
---@data Sun May 18 2025 15:12:41 GMT+0800 (中国标准时间)
---

local ELStatus = require('Ikun/Module/AI/BT/ELStatus')

---@class LDecorator_BBCondition: LDecorator
---@field CondBBKeyName string
local LDecorator_BBCondition = class.class 'LDecorator_BBCondition' : extends 'LDecorator' {
--[[private]]
    CondBBKeyName = nil,
}
function LDecorator_BBCondition:ctor(NodeDispName, CondBBKeyName)
    class.LDecorator.ctor(self, NodeDispName)
    self.CondBBKeyName = CondBBKeyName
end
function LDecorator_BBCondition:Judge()
    if not self.Blackboard then
        return false
    end
    local Result = self.Blackboard:GetBBValue(self.CondBBKeyName)
    if not Result then
        return false
    end
    return true
end
function LDecorator_BBCondition:PrintNode(nDeep)
    local Text = ''
    if nDeep > 0 then
        for i = 1, nDeep do
            Text = Text .. '        '
        end
    end
    Text = Text .. string.format('Decorator : %s [%s] : %s\n',self.NodeDispName, self.CondBBKeyName, ELStatus.PrintLStatus(self.LastStatus))
    Text = Text .. self.Child:PrintNode(nDeep)
    return Text
end
