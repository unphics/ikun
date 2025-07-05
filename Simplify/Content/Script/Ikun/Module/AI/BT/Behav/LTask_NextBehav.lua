
---
---@brief   下一个行为
---@author  zys
---@data    Wed Jun 18 2025 22:31:19 GMT+0800 (中国标准时间)
---

local BehavDef = require("Ikun.Module.AI.BT.Behav.BehavDef")
local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LTask_NextBehav : LTask
local LTask_NextBehav = class.class 'LTask_NextBehav' : extends 'LTask' {
--[[public]]
    ctor = function()end,
    OnInit = function()end,
    OnUpdate = function()end,
--[[private]]
}
function LTask_NextBehav:ctor(NodeDispName)
    class.LTask.ctor(self, NodeDispName)
end
function LTask_NextBehav:OnInit()
    class.LTask.OnInit(self)
    local CurBehav = self.Blackboard:GetBBValue(BBKeyDef.CurBehav)
    local NextBehav = self.Blackboard:GetBBValue(BBKeyDef.NextBehav)

    if NextBehav then
        self.Blackboard:SetBBValue(BBKeyDef.LastBehav, CurBehav)
        self.Blackboard:SetBBValue(BBKeyDef.CurBehav, NextBehav)
        self.Blackboard:SetBBValue(BBKeyDef.NextBehav, nil)
    end
end
function LTask_NextBehav:OnUpdate()
    self:DoTerminate(true)
end