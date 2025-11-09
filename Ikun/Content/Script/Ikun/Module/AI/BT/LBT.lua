---
---@brief LuaBehaviourTree
---@author zys
---@data Sun Jan 19 2025 20:16:03 GMT+0800 (中国标准时间)
---@desc 出于灵活考虑, 写一个纯脚本的行为树代替UE的行为树
---      代码参考这个 https://www.cnblogs.com/OwlCat/p/17871494.html
---      使用参考UE行为树
---

require('Ikun/Module/AI/BT/NodeCore')
require('Ikun/Module/AI/BT/NodeDef')
require('Ikun/Module/AI/BT/Blackboard')

---@class LBT Lua行为树
---@field Ctlr AAIController
---@field Chr ACharacter
---@field Desc string 行为树说明
---@field Blackboard BlackboardClass 行为树的黑板
---@field Root LNode 行为树的根节点
---@field CurModiCompStack LComposite[] 当前在修改的组合节点; 开发中使用
---@field CurNodeCanChild LNode 当前可有Child的节点; 开发中使用
---@field CurRunningTaskName string 当前在跑的Task的Name
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
    Desc = nil,
--[[private]]
    AddBack = function()end,
    InitNode = function()end,
    Ctlr = nil,
    Chr = nil,
    Root = nil,
    Blackboard = nil,
    CurModiCompStack = nil,
    CurNodeCanChild = nil,
    CurRunningTaskName = nil,
}
---@param Ctlr AAIController
---@param Chr ACharacter
---@param Desc string
function LBT:ctor(Ctlr, Chr, Desc)
    self.Ctlr = Ctlr
    self.Chr = Chr
    self.Desc = Desc
    self.Blackboard = class.new 'BlackboardClass' ()
end
---@private 对于新创建的节点, 初始化一些基本数据
function LBT:InitNode(Node, Name)
    if not Node then
        error('创建行为树Node失败 - ' .. Name)
        return
    end
    Node.Ctlr = self.Ctlr
    Node.Chr = self.Chr
    Node.Blackboard = self.Blackboard
    Node.LBT = LBT
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
function LBT:AddSelector(DebugCode)
    local Node = class.new 'LSelector' ('Select', DebugCode)
    self:InitNode(Node, 'Selector')
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
    if not TaskName then
        log.error('LBT:AddTask() Need but not valid arg: TaskName')
        return self
    end
    
    local Node = class.new (TaskName) (TaskName, ...)
    self:InitNode(Node, TaskName)

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
    if not Name then
        log.error('LBT:AddDecorator() Need but not valid arg: Name')
        return self
    end

    local Node = class.new (Name) (Name, ...)
    self:InitNode(Node, Name)

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
    if not Name then
        log.error('LBT:AddService() Need but not valid arg: Name')
        return self
    end

    local Node = class.new (Name) (Name, TickInterval, ...)
    self:InitNode(Node, Name)

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
    local strName = 'Name: ' .. obj_util.dispname(self.Chr)
    local Role = self.Chr:GetRole() ---@type RoleClass
    local strId = ', Id : ' .. Role:GetRoleId()
    PrintText = PrintText .. strName .. strId .. '\n'
    PrintText = PrintText .. 'BT: ' .. self.Desc .. '\n'
    PrintText = PrintText .. self.Root:PrintNode(0)
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