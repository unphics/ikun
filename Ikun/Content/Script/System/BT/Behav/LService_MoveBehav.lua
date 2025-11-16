
---
---@brief   角色的移动行为
---@author  zys
---@data    Wed Jun 18 2025 23:49:52 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")
local NavMoveBehav = require('Ikun/Module/Nav/NavMoveBehav')

---@class LService_MoveBehav: LService
---@field NavMoveBehav NavMoveBehav
local LService_MoveBehav = class.class 'LService_MoveBehav' : extends 'LService' {
--[[public]]
    ctor = function()end,
    OnInit = function()end,
    OnUpdate = function()end,
--[[private]]
    NavMoveBehav = nil,
}
function LService_MoveBehav:ctor(NodeDispName, TickInterval)
    class.LService.ctor(self, NodeDispName, TickInterval)
end
function LService_MoveBehav:OnInit()
    class.LService.OnInit(self)
    if not self.NavMoveBehav then
        self.NavMoveBehav = class.new 'NavMoveBehav' (self.Chr, 5)
        self.Blackboard:SetBBValue(BBKeyDef.MoveBehavObj, self.NavMoveBehav)
    end
end
function LService_MoveBehav:OnUpdate(DeltaTime)
    class.LService.OnUpdate(self, DeltaTime)
    self.NavMoveBehav:TickMove(DeltaTime)
end