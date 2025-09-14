---
---@brief   WaitTime
---@author  zys
---@data    Sun Jan 26 2025 22:56:00 GMT+0800 (中国标准时间)
---

local ELStatus = require('Ikun/Module/AI/BT/ELStatus')

---@class LTask_Wait : LTask
---@field ConstWaitTime number
---@field ConstRandom number
---@field CurTime number
local LTask_Wait = class.class 'LTask_Wait' : extends 'LTask' {
    ctor = function()end,
    ConstWaitTime = nil,
}
---@param WaitTime number
function LTask_Wait:ctor(TaskName, WaitTime, Random)
    class.LTask.ctor(self, TaskName)
    self.ConstWaitTime = WaitTime or 2
    self.ConstRandom = Random or 0
end
function LTask_Wait:OnInit()
    class.LTask.OnInit(self)
    self.WaitTime = self.ConstWaitTime + (math.random() - 0.5) * 2 * self.ConstRandom
    self.CurTime = 0
end
function LTask_Wait:OnUpdate(DeltaTime)
    self.CurTime = self.CurTime + DeltaTime
    if self.CurTime > self.WaitTime then
        self:DoTerminate(true)
    end
end
function LTask_Wait:OnTerminate()
    class.LTask.OnTerminate(self)
end
function LTask_Wait:PrintNode(nDeep)
    local Text = ''
    if nDeep > 0 then
        for i = 1, nDeep do
            Text = Text .. '        '
        end
    end
    local CurTime = self.CurTime and string.format('%02.1f', self.WaitTime - self.CurTime) or 'nil'
    Text = Text .. 'Task : ' .. self.NodeDispName .. '-' .. CurTime .. ' : ' .. ELStatus.PrintLStatus(self.LastStatus) .. '\n'
    return Text
end