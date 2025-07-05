---
---@brief LBT的核心基础套件
---@author zys
---@data Tue Apr 15 2025 01:00:25 GMT+0800 (中国标准时间)
---

local ELStatus = require('Ikun/Module/AI/BT/ELStatus')

---@class LNode 基节点, 包含所有节点的共用功能
---@field NodeDispName string
---@field NodeName string
---@field Status ELStatus
---@field LastStatus ELStatus
---@field Blackboard BlackboardClass
---@field Chr BP_ChrBase
---@field Ctlr AAIController
---@field LBT LBT
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
    NodeDispName = 'Node',
    Blackboard = nil,
--[[private]]
    SetStatus = function()end,
    GetStatus = function()end,
    Status = ELStatus.Invalid,
    LastStatus = ELStatus.Invalid,
    NodeName = nil,
    LBT = nil,
}
function LNode:ctor(NodeDispName)
    self.Status = ELStatus.Invalid
    self.NodeDispName = NodeDispName
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
    return self.NodeDispName .. ' :\n'
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
    ctor = function(NodeDispName)end,
    PrintNode = function(nDeep)end,
    bComposite = true,
--[[private]]
    Children = nil,
}
function LComposite:ctor(NodeDispName)
    class.LNode.ctor(self, NodeDispName)
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
    Text = Text .. self.NodeDispName .. ' : ' .. ELStatus.PrintLStatus(self.LastStatus) .. '\n'
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
function LSequence:ctor(NodeDispName)
    class.LComposite.ctor(self, NodeDispName)
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
---@field ConstDebugCode number
local LSelector = class.class'LSelector' : extends 'LSequence' {
    ctor = function()end,
    OnUpdate = function()end,
    ConstDebugCode = nil,
}
function LSelector:ctor(NodeDispName, DebugCode)
    class.LSequence.ctor(self, NodeDispName)
    self.ConstDebugCode = DebugCode
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