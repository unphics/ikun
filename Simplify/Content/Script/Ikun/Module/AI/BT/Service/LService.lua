
local ELStatus = require('Ikun/Module/AI/BT/ELStatus')

---@class LService: LDecorator
---@field StaticTickInterval number
local LService = class.class 'LService' : extends 'LDecorator' {
    ctor = function()end,
}
---@param TickInterval number
function LService:ctor(DisplayName, TickInterval)
    class.LDecorator.ctor(self, DisplayName)
    self.StaticTickInterval = TickInterval
end
function LService:OnInit()
    self.CurTickCount = 0
end
function LService:DoUpdate(DeltaTime)
    if self.Child then
        self.CurTickCount = self.CurTickCount + DeltaTime
        if self.CurTickCount > self.StaticTickInterval then
            self.CurTickCount = self.CurTickCount - self.StaticTickInterval
            self:OnUpdate(DeltaTime)
            if self:IsTerminated() then
                return self:GetStatus()
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
    Text = Text .. 'Service : ' .. self.DisplayName .. ' : ' .. ELStatus.PrintLStatus(self.LastStatus) .. '\n'
    Text = Text .. self.Child:PrintNode(nDeep)
    return Text
end