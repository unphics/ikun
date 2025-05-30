---
---@brief   模块管理器
---@desc    所有纯逻辑模块在这里拉起; MdMgr在GameInstance中被拉起
---@author  zys
---@data    Sun Dec 15 2024 11:27:34 GMT+0800 (中国标准时间)
---

require("Ikun.Module.MdBase")
require("Content/Area/Cosmos")
require('Content/Time/TimeMgr')
require('Content/Role/RoleMgr')

---@class MdMgr
---@field Cosmos Cosmos 游戏宇宙
---@field RoleMgr RoleMgrClass 角色管理器
---@field TimerMgr TimeMgr
local MdMgr = class.class "MdMgr" : extends "MdBase" {
--[[public]]
    ctor = function()end,
    Init = function()end,
    Tick = function(DeltaTime)end,
    MdName = "MdMgr",
    Cosmos = nil,
}
---@private [override]
function MdMgr:Init()
    class.MdBase.Init(self)
    self.Cosmos = class.new "Cosmos"()
    self.TimeMgr = class.new 'TimeMgr'()
    self.RoleMgr = class.new 'RoleMgrClass'()
    self.Cosmos:Init()
    self.TimeMgr:Init()
    self.RoleMgr:Init()
end
---@private [override]
function MdMgr:Tick(DeltaTime)
    self.Cosmos:Tick(DeltaTime)
    self.TimeMgr:Tick(DeltaTime)
    -- self.RoleMgr:Tick(DeltaTime)
end