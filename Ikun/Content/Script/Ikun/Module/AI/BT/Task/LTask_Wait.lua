
local ELStatus = require('Ikun/Module/AI/BT/ELStatus')

---@class LTask_Wait : LTask
---@field WaitTime number
---@field CurTime number
local LTask_Wait = class.class 'LTask_Wait' : extends 'LTask' {
    ctor = function()end,
    WaitTime = nil,
}
---@param WaitTime number
function LTask_Wait:ctor(TaskName, WaitTime)
    class.LTask.ctor(self, TaskName)
    self.WaitTime = WaitTime or 2
end
function LTask_Wait:OnInit()
    class.LTask.OnInit(self)
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
    local CurTime = self.CurTime and string.format('%02.1f', self.CurTime) or 'nil'
    Text = Text .. 'Task : ' .. self.DisplayName .. '-' .. CurTime .. ' : ' .. ELStatus.PrintLStatus(self.LastStatus) .. '\n'
    return Text
end