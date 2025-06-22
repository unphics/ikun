
local ELStatus = require('Ikun/Module/AI/BT/ELStatus')

---@class LService: LDecorator
---@field StaticTickInterval number
local LService = class.class 'LService' : extends 'LDecorator' {
    ctor = function()end,
}
---@param TickInterval number
function LService:ctor(NodeDispName, TickInterval)
    class.LDecorator.ctor(self, NodeDispName)
    self.StaticTickInterval = TickInterval or log.error('LService:ctor() no tick interval')
end
function LService:OnInit()
    if not self.CurTickCount then
        self.CurTickCount = 0
    end
end
function LService:DoUpdate(DeltaTime)
    if self.Child then
        if self.StaticTickInterval == 0 then
            self.CurTickCount = DeltaTime
            self:OnUpdate(DeltaTime)
            -- if self:IsTerminated() then
            --     return self:GetStatus()
            -- end
        else
            self.CurTickCount = self.CurTickCount + DeltaTime
            if self.CurTickCount > self.StaticTickInterval then
                self.CurTickCount = self.CurTickCount - self.StaticTickInterval
                self:OnUpdate(self.StaticTickInterval)
                -- if self:IsTerminated() then
                --     return self:GetStatus()
                -- end
            end
        end
        self.Child:Tick(DeltaTime)
        return self.Child:GetStatus()
    end
    return ELStatus.Failure
end
function LService:OnUpdate(DeltaTime)
end
function LService:PrintNode(nDeep)
    local Text = ''
    if nDeep > 0 then
        for i = 1, nDeep do
            Text = Text .. '        '
        end
    end
    Text = Text .. 'Service : ' .. self.NodeDispName .. ' : ' .. ELStatus.PrintLStatus(self.LastStatus) .. '\n'
    Text = Text .. self.Child:PrintNode(nDeep)
    return Text
end