
local ELStatus = require('Ikun/Module/AI/BT/ELStatus')

---@class LDecorator: LNode 装饰器
---@field Child LNode
---@field Result boolean
local LDecorator = class.class 'LDecorator': extends 'LNode' {
--[[public]]
    ctor = function()end,
    SetChild = function()end,
    DoUpdate = function()end,
    OnUpdate = function(DeltaTime)end,
    Judge = function()end,
--[[private]]
    Child = nil,
    Result = nil,
}
function LDecorator:ctor(DisplayName)
    class.LNode.ctor(self, DisplayName)
end
function LDecorator:SetChild(Node)
    self.Child = Node
end
function LDecorator:OnInit()
    self.Result = self:Judge()
end
function LDecorator:Judge()
    return false
end
function LDecorator:DoUpdate(DeltaTime)
    local Status = self:OnUpdate(DeltaTime)
    if Status == ELStatus.Success then
        if self.Child then
            self.Child:Tick(DeltaTime)
            return self.Child:GetStatus()
        else
            return ELStatus.Failure
        end
    else
        return Status
    end
end
-- 装饰器瞬间出结果, 失败则整体失败, 成功则保持成功直到子节点成功或失败
-- 瞬间结果成功则装饰器成功, 子节点失败则装饰器失败
function LDecorator:OnUpdate(DeltaTime)
    return self.Result and ELStatus.Success or ELStatus.Failure
end
function LDecorator:PrintNode(nDeep)
    local Text = ''
    if nDeep > 0 then
        for i = 1, nDeep do
            Text = Text .. '        '
        end
    end
    Text = Text .. 'Decorator : ' .. self.DisplayName .. ' : ' .. ELStatus.PrintLStatus(self.LastStatus) .. '\n'
    Text = Text .. self.Child:PrintNode(nDeep)
    return Text
end