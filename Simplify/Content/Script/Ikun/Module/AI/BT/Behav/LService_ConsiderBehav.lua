---
---@brief   行为选择
---@author  zys
---@data    Tue Jun 17 2025 22:41:45 GMT+0800 (中国标准时间)
---@desc    做成Service的原因是: 角色时刻在思考, 有时候会有很好的时机, 但是也会因为正在做其他事情错过, 但是其实能遇到
---@version 0.1 所有的参数先都硬编码在代码里, 后面考虑根据角色的设定来调整
---@ref     
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")
local BehavDef = require("Ikun.Module.AI.BT.Behav.BehavDef")

---@class LService_ConsiderBehav : LService
local LService_ConsiderBehav = class.class 'LService_ConsiderBehav' : extends 'LService' {
--[[public]]
    ctor = function()end,
    OnUpdate = function()end,
--[[private]]
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

    local canAttack = true -- 有攻击技能
    local canSupport = false -- 有支援技能
    local canDisturb = canAttack -- 能进攻就能骚扰
    
    ---@class ConsiderContext
    local Context = {
        canAttack = canAttack,
        canSupport = canSupport,
        canDisturb = canDisturb,
        Health = self.Chr.AttrSet:GetAttrValueByName("Health"),
        MaxHealth = self.Chr.AttrSet:GetAttrValueByName("MaxHealth"),
        NeedSupportMemberCount = 0,
        AllMemberCount = 10,
        LastBehav = self.Blackboard:GetBBValue(BBKeyDef.LastBehav),
        CurBehav = self.Blackboard:GetBBValue(BBKeyDef.CurBehav),
    }
    if self:NeedSurvive(Context) then
        self.Blackboard:SetBBValue(BBKeyDef.NextBehav, BehavDef.Survive)
    elseif self:CanSupport(Context) then
        self.Blackboard:SetBBValue(BBKeyDef.NextBehav, BehavDef.Support)
    elseif self:CanAttack(Context) then
        self.Blackboard:SetBBValue(BBKeyDef.NextBehav, BehavDef.Attack)
    end
end
---@private 单位此时需要着重考虑自己的存活
---@param Context ConsiderContext
function LService_ConsiderBehav:NeedSurvive(Context)
    if (Context.Health / Context.MaxHealth) < 0.3 then
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
    if not (Context.NeedSupportMemberCount > 0) then
        return false
    end
    ---@todo 此处考虑角色个人的进攻意愿设定和支援意愿设定
    if Context.CurBehav == BehavDef.Attack and math.random() > 0.2 then
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

return LService_ConsiderBehav