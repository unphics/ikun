
local ELStatus = require('Ikun/Module/AI/BT/ELStatus')

---@class LTask: LNode
local LTask = class.class 'LTask': extends 'LNode' {
    OnUpdate = function(DeltaTime)end,
    PrintNode = function()end,
}
function LTask:OnInit()
    self:SetStatus(ELStatus.Running)
end
function LTask:DoUpdate(DeltaTime)
    if self:IsRunning() then
        self:OnUpdate(DeltaTime)
        self.LBT.CurRunningTaskName = self.NodeDispName
    end
    return self:GetStatus()
end
function LTask:OnUpdate(DeltaTime)
    self.TimeCount = self.TimeCount + DeltaTime
    if self.TimeCount > self.Threshold then
        if self.NodeDispName == '失败' then
            self:DoTerminate(false)
        else
            self:DoTerminate(true)
        end
    end
    -- return ELStatus.Success
end
-- function LTask:OnTerminate()
-- end
function LTask:PrintNode(nDeep)
    local Text = ''
    if nDeep > 0 then
        for i = 1, nDeep do
            Text = Text .. '        '
        end
    end
    Text = Text .. 'Task : ' .. self.NodeDispName .. ' : ' .. ELStatus.PrintLStatus(self.LastStatus) .. '\n'
    return Text
end