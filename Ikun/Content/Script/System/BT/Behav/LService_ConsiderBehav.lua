---
---@brief   行为选择
---@author  zys
---@data    Tue Jun 17 2025 22:41:45 GMT+0800 (中国标准时间)
---@desc    做成Service的原因是: 角色时刻在思考, 有时候会有很好的时机, 但是也会因为正在做其他事情错过, 但是其实能遇到
---@version 0.1 所有的参数先都硬编码在代码里, 后面考虑根据角色的设定来调整
---@ref     
---

local ELStatus = require('Ikun/Module/AI/BT/ELStatus')
local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")
local BehavDef = require("Ikun.Module.AI.BT.Behav.BehavDef")

---@class LService_ConsiderBehav : LService
local LService_ConsiderBehav = class.class 'LService_ConsiderBehav' : extends 'LService' {
--[[public]]
    ctor = function()end,
    OnUpdate = function()end,
--[[private]]
    HasSpecial = function()end,
    NeedSurvive = function()end,
    CanSupport = function()end,
    CanAttack = function()end,
}
---@override
function LService_ConsiderBehav:ctor(NodeDispName, TickInterval)
    class.LService.ctor(self, NodeDispName, TickInterval)
end
---@override
function LService_ConsiderBehav:OnUpdate(DeltaTime)
    class.LService.OnUpdate(self, DeltaTime)
    local NoSupportCount = self.Chr:GetRole().Team.TeamSupport:GetNoSupportCount()
    
    ---@class ConsiderContext 思考上下文, 内建数据结构; 不可外部传播, 有导致结构混乱的风险
    ---@field canAttack boolean 有攻击技能
    ---@field canSupport boolean 有支援技能
    ---@field canDisturb boolean 能骚扰
    ---@field Health number 血量
    ---@field MaxHealth number 最大血量
    ---@field NeedSupportMemberCount number 需要支援的成员的数量
    ---@field AllMember number 所有友军数量
    ---@field LastBehav BehavDef 上一个行为
    ---@field CurBehav BehavDef 当前行为
    local Context = {
        canAttack = true,
        canSupport = true,
        canDisturb = true,
        Health = self.Chr.AttrSet:GetAttrValueByName("Health"),
        MaxHealth = self.Chr.AttrSet:GetAttrValueByName("MaxHealth"),
        NeedSupportMemberCount = NoSupportCount,
        AllMemberCount = 10,
        LastBehav = self.Blackboard:GetBBValue(BBKeyDef.LastBehav),
        CurBehav = self.Blackboard:GetBBValue(BBKeyDef.CurBehav),
    }
    if self:HasSpecial(Context) then
        self.Blackboard:SetBBValue(BBKeyDef.NextBehav, BehavDef.Special)
    elseif self:NeedSurvive(Context) then
        self.Blackboard:SetBBValue(BBKeyDef.NextBehav, BehavDef.Survive)
    elseif self:CanSupport(Context) then
        self.Blackboard:SetBBValue(BBKeyDef.NextBehav, BehavDef.Support)
    elseif self:CanAttack(Context) then
        self.Blackboard:SetBBValue(BBKeyDef.NextBehav, BehavDef.Attack)
    end
end
---@private 单位有需要执行的特殊行为
---@todo 其实是Team要求，后面拆分一下
---@param Context ConsiderContext
function LService_ConsiderBehav:HasSpecial(Context)
    local Role = self.Chr:GetRole() ---@type RoleBaseClass
    local Team = Role.Team
    if not Team.CurTB.DirectiveMoveCoord then
        return false
    end
    local vec = Team.CurTB.DirectiveMoveCoord[Role:GetRoleId()]
    if vec then
        return true
    end
    return false
end
---@private 单位此时需要着重考虑自己的存活
---@param Context ConsiderContext
function LService_ConsiderBehav:NeedSurvive(Context)
    if (Context.Health / Context.MaxHealth) < 0.35 then
        return true
    end
    return false
end
---@private 单位此时可以支援其他单位
---@param Context ConsiderContext
function LService_ConsiderBehav:CanSupport(Context)
    if not Context.canSupport then
        return false
    end
    if Context.NeedSupportMemberCount == 0 then
        return false
    end
    ---@todo 此处考虑角色个人的进攻意愿设定和支援意愿设定
    if Context.CurBehav == BehavDef.Attack and math.random() > 0.5 then
        return false
    end
    return true
end
---@private 单位此时可以进攻对方单位
---@param Context ConsiderContext
function LService_ConsiderBehav:CanAttack(Context)
    if not Context.canAttack then
        return false
    end
    return true
end
---@private
function LService_ConsiderBehav:PrintNode(nDeep)
    local Text = ''
    if nDeep > 0 then
        for i = 1, nDeep do
            Text = Text .. '        '
        end
    end
    local LastBehav = self.Blackboard:GetBBValue(BBKeyDef.LastBehav) or 'nil'
    local CurBehav = self.Blackboard:GetBBValue(BBKeyDef.CurBehav) or 'nil'
    local NextBehav = self.Blackboard:GetBBValue(BBKeyDef.NextBehav) or 'nil'
    local StrBehavStatus = 'LastBehav:' .. LastBehav .. ', CurBehav:' .. CurBehav .. ', NextBehav:' .. NextBehav
    Text = Text .. 'Service : ' .. self.NodeDispName .. ' : ' .. ELStatus.PrintLStatus(self.LastStatus) .. StrBehavStatus .. '\n'
    Text = Text .. self.Child:PrintNode(nDeep)
    return Text
end

return LService_ConsiderBehav