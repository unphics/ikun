
---
---@brief   找一个需要被支援的目标
---@author  zys
---@data    Sat Jul 05 2025 01:06:04 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LTask_FindSupportTarget : LTask
local LTask_FindSupportTarget = class.class 'LTask_FindSupportTarget' : extends 'LTask' {
--[[public]]
    ctor = function()end,
    OnInit = function()end,
--[[private]]
    OnUpdate = function()end,
}
---@override
function LTask_FindSupportTarget:ctor(NodeDispName)
    class.LTask.ctor(self, NodeDispName)
end
---@override
function LTask_FindSupportTarget:OnInit()
    class.LTask.OnInit(self)
    if self.Blackboard:GetBBValue(BBKeyDef.SupportTarget) then
        return
    end
    local role = self.Chr:GetRole()
    local team = role.Team
    local req = team.TeamSupport:BeginSupport(role)
    self.Blackboard:SetBBValue(BBKeyDef.SupportTarget, req)
end
function LTask_FindSupportTarget:OnUpdate()
    if self.Blackboard:GetBBValue(BBKeyDef.SupportTarget) then
        self:DoTerminate(true)
    else
        self:DoTerminate(false)
    end
end

return LTask_FindSupportTarget