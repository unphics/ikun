---
---@brief LuaBehaviourTree
---@desc 出于灵活考虑, 后面打算写一个纯脚本的行为树代替UE的行为树
---      代码参考这个 https://www.cnblogs.com/OwlCat/p/17871494.html
---      使用参考UE行为树

local ELStatus = require('Ikun/Module/AI/BT/ELStatus')

---@param Status
local function PrintLStatus(Status)
    local Arr = {'Failure', 'Success', 'Running', 'Aborted', 'Invalid'}
    local Text = Arr[Status]
    if Text == 'Running' then
        Text = Text .. '    <---------'
    end
    return Text
end

---@class LNode 基节点, 包含所有节点的共用功能
---@field DisplayName string
---@field NodeName string
---@field Status ELStatus
---@field LastStatus ELStatus
---@field Chr BP_ChrBase
---@field Ctlr AAIController
local LNode = class.class 'LNode' {
--[[public]]
    ctor = function()end,
    Tick = function(DeltaTime)end,
    DoUpdate = function()end,
    OnUpdate = function()end,
    OnInit = function()end,
    DoTerminate = function(bSuccess)end,
    OnTerminate = function()end,
    IsTerminated = function()end,
    IsSuccess = function()end,
    IsFailure = function()end,
    IsRunning = function()end,
    PrintNode = function(nDeep)end,
    Reset = function()end,
    Abort = function()end,
    Ctlr = nil,
    Chr = nil,
    DisplayName = 'Node',
--[[private]]
    SetStatus = function()end,
    GetStatus = function()end,
    Status = ELStatus.Invalid,
    LastStatus = ELStatus.Invalid,
    NodeName = nil
}
function LNode:ctor(DisplayName)
    self.Status = ELStatus.Invalid
    self.DisplayName = DisplayName
    self.NodeName = self.__class_name
end
function LNode:OnInit()
end
-- Tick此节点, 若未在运行则初始化, 运行中调用Update, 若已有结果则调用结束回调
function LNode:Tick(DeltaTime)
    if not self:IsRunning() then
        self:OnInit()
    end
    local Status = self:DoUpdate(DeltaTime)
    self:SetStatus(Status)
    if not self:IsRunning() then
        self:OnTerminate()
    end
    self.LastStatus = self.Status
end
function LNode:DoUpdate(DeltaTime)
    return self:OnUpdate(DeltaTime)
end
function LNode:OnUpdate(DeltaTime)
    return ELStatus.Failure
end
function LNode:PrintNode(nDeep)
    return self.DisplayName .. ' :\n'
end
function LNode:IsTerminated()
    return self:IsSuccess() or self:IsFailure()
end
function LNode:DoTerminate(bSuccess)
    self:SetStatus(bSuccess and ELStatus.Success or ELStatus.Failure)
end
function LNode:OnTerminate()
end
function LNode:IsSuccess()
    return self:GetStatus() == ELStatus.Success
end
function LNode:IsFailure()
    return self:GetStatus() == ELStatus.Failure
end
function LNode:IsRunning()
    return self:GetStatus() == ELStatus.Running
end
function LNode:Reset()
    self:SetStatus(ELStatus.Invalid)
end
function LNode:Abort()
    self:OnTerminate()
    self:SetStatus(ELStatus.Aborted)
end
function LNode:SetStatus(NewStatus)
    self.Status = NewStatus
end
function LNode:GetStatus()
    return self.Status
end


---@class LComposite: LNode 组合节点, 有多个子节点
---@field bComposite boolean
local LComposite = class.class 'LComposite' : extends 'LNode' {
--[[public]]
    ctor = function(DisplayName)end,
    PrintNode = function(nDeep)end,
    bComposite = true,
--[[private]]
    Children = nil,
}
function LComposite:ctor(DisplayName)
    class.LNode.ctor(self, DisplayName)
    self.Children = {}
end
function LComposite:AddChild(Node)
    table.insert(self.Children, Node)
end
function LComposite:PrintNode(nDeep)
    local Text = ''
    if nDeep > 0 then
        for i = 1, nDeep do
            Text = Text .. '        '
        end
    end
    Text = Text .. self.DisplayName .. ' : ' .. PrintLStatus(self.LastStatus) .. '\n'
    if self.Children then
        for _, Node in ipairs(self.Children) do
            Text = Text .. Node:PrintNode(nDeep + 1)
        end
    end
    return Text
end


---@class LSequence: LComposite 顺序器;从左到右顺序执行,当其中任何一个子节点执行失败时顺序器执行失败,所有子节点都执行成功则顺序器执行成功
---@field CurNode LNode
---@field CurIdx number
local LSequence = class.class 'LSequence' : extends 'LComposite' {
--[[public]]
    ctor = function()end,
    OnInit = function ()end,
    OnUpdate = function(DeltaTime)end,
--[[private]]
    CurNode = nil,
    CurIdx = nil
}
function LSequence:ctor(DisplaName)
    class.LComposite.ctor(self, DisplaName)
end
function LSequence:OnInit()
    self.CurNode = self.Children[1]
    self.CurIdx = 1
    self:SetStatus(ELStatus.Running)
end
function LSequence:OnUpdate(DeltaTime)
    while true do
        self.CurNode:Tick(DeltaTime)
        local s = self.CurNode:GetStatus()
        if s ~= ELStatus.Success then
            return s
        end
        if self.CurIdx >= #self.Children then
            return ELStatus.Success
        end
        self.CurIdx = self.CurIdx + 1
        self.CurNode = self.Children[self.CurIdx]
    end
end


---@class LSelector: LSequence 选择器
local LSelector = class.class'LSelector' : extends 'LSequence' {
    ctor = function()end,
    OnUpdate = function()end,
}
function LSelector:ctor(DisplayName)
    class.LSequence.ctor(self, DisplayName)
end
-- 选择器Tick当前节点, 失败则换下一个, 否则就一直Tick当前节点
-- 只要有一个成功, 则选择器成功; 如果都失败, 则选择器失败
function LSelector:OnUpdate(DeltaTime) 
    while true do
        if not self.CurNode then
            return ELStatus.Failure
        end
        self.CurNode:Tick(DeltaTime)
        local s = self.CurNode:GetStatus()
        if s ~= ELStatus.Failure then
            return s
        end
        if self.CurIdx >= #self.Children then
            return ELStatus.Failure
        end
        self.CurIdx = self.CurIdx + 1
        self.CurNode = self.Children[self.CurIdx]
    end
end


require('Ikun/Module/AI/BT/Task/LTask')
require('Ikun/Module/AI/BT/Task/LTask_Wait')
require('Ikun/Module/AI/BT/Task/LTask_AiMoveBase')
require('Ikun/Module/AI/BT/Task/LTask_RandNavTarget')
require('Ikun/Module/AI/BT/Task/LTask_RotateSmooth')

require('Ikun/Module/AI/BT/Decorator/LDecorator')
require('Ikun/Module/AI/BT/Decorator/LDecorator_RoleCond')

require('Ikun/Module/AI/BT/Service/LService')
require('Ikun/Module/AI/BT/Service/LService_Alert')

---@class LBT Lua行为树
---@field Ctlr AAIController
---@field Chr ACharacter
---@field CurModiCompStack LComposite[] 当前在修改的组合节点
local LBT = class.class 'LBT' {
--[[public]]
    ctor = function(Ctlr, Chr)end,
    Tick = function(DeltaTime)end,
    PrintBT = function()end,
    CreateRoot = function()end,
    AddCompsite = function()end,
    Up = function()end,
    AddSelector = function()end,
    AddSequence = function()end,
    AddTask = function()end,
    AddDecorator = function()end,
    AddService = function()end,
    InitNode = function(Node)end,
--[[private]]
    AddBack = function()end,
    Ctlr = nil,
    Chr = nil,
    Root = nil,
    CurModiCompStack = nil,
    CurNodeCanChild = nil,
}
---@param Ctlr AAIController
---@param Chr ACharacter
function LBT:ctor(Ctlr, Chr)
    self.Ctlr = Ctlr
    self.Chr = Chr
end
function LBT:InitNode(Node)
    Node.Ctlr = self.Ctlr
    Node.Chr = self.Chr
end
function LBT:CreateRoot()
    self.Root = class.new'LSelector'('Root')
    self.CurModiCompStack = {}
    table.insert(self.CurModiCompStack, self.Root)
    self.CurNodeCanChild = self.Root
    return self
end
function LBT:Tick(DeltaTime)
    self.Root:Tick(DeltaTime)
end
-- 跳到上一个复合节点, 然后此复合节点变成最后一个可挂接的Node
function LBT:Up()
    table.remove(self.CurModiCompStack, #self.CurModiCompStack)
    self.CurNodeCanChild = self.CurModiCompStack[#self.CurModiCompStack]
    return self
end
function LBT:AddCompsite(LCompositeNode)
    if self.CurNodeCanChild.bComposite then    
        self.CurNodeCanChild:AddChild(LCompositeNode)
    else
        self.CurNodeCanChild:SetChild(LCompositeNode)
    end
    table.insert(self.CurModiCompStack, LCompositeNode)
    self.CurNodeCanChild = LCompositeNode
    return self
end
-- 添加到最后一个可挂接Child的Node上, 然后选择器变成最后一个可挂接的Node
function LBT:AddSelector()
    local Node = class.new 'LSelector' ('Select')
    return self:AddCompsite(Node)
end
-- 添加到最后一个可挂接Child的Node上, 然后顺序器变成最后一个可挂接的Node
function LBT:AddSequence()
    local Node = class.new 'LSequence' ('Sequence')
    return self:AddCompsite(Node)
end
function LBT:AddBack(Node)
    return self
end
-- 添加到最后一个可挂接Child的Node上, 然后上一个CompsiteNode变成最后一个可挂接Child的Node
function LBT:AddTask(TaskName, ...)
    local Node = class.new (TaskName) (TaskName, ...)
    self:InitNode(Node)

    if self.CurNodeCanChild.bComposite then    
        self.CurNodeCanChild:AddChild(Node)
    else
        self.CurNodeCanChild:SetChild(Node)
    end
    self.CurNodeCanChild = self.CurModiCompStack[#self.CurModiCompStack]

    return self
end
-- 添加到最后一个可挂接Child的Node上, 然后装饰器变成最后一个可挂接Child的Node
function LBT:AddDecorator(Name, ...)
    local Node = class.new (Name) (Name, ...)
    self:InitNode(Node)

    if self.CurNodeCanChild.bComposite then    
        self.CurNodeCanChild:AddChild(Node)
    else
        self.CurNodeCanChild:SetChild(Node)
    end

    self.CurNodeCanChild = Node
    return self
end
---@param TickInterval number
function LBT:AddService(Name, TickInterval, ...)
    local Node = class.new (Name) (Name, TickInterval, ...)
    self:InitNode(Node)

    if self.CurNodeCanChild.bComposite then    
        self.CurNodeCanChild:AddChild(Node)
    else
        self.CurNodeCanChild:SetChild(Node)
    end

    self.CurNodeCanChild = Node
    return self
end
---@return string
function LBT:PrintBT()
    local PrintText = ''
    if not self.Chr or not obj_util.is_valid(self.Chr) then
        PrintText = PrintText .. 'InValid Chr !!!'
        return PrintText
    end
    PrintText = PrintText .. 'DisplayName: ' .. obj_util.display_name(self.Chr)
    PrintText = PrintText .. '\n' .. self.Root:PrintNode(0)
    return PrintText
end

--[[
                  Root
                    ↓
                  Select
                ↙       ↘
          有目标           Sequence
        Sequence          ↙  ↓  ↘
     ↙  ↓   ↓  ↘    选地点 转身 巡逻走
选技能 转身 移动 放技能

local LBT = class.new 'LBT' (nil, self) ---@type LBT
LBT:CreateRoot() -- Root
    :AddSelector()
        :AddCondition('有目标')
        :AddSequence()
            :AddTask('选技能')
            :AddTask('转身')
            :AddTask('移动')
            :AddTask('放技能')
        :Up()
        :AddSuquence()
            :AddTask('选地点')
            :AddTask('转身')
            :AddTask('巡逻走')

]]