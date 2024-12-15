---
---@brief   模块管理器
---@desc    所有纯逻辑模块在这里拉起; MdMgr在GameInstance中被拉起
---@author  zys
---@data    Sun Dec 15 2024 11:27:34 GMT+0800 (中国标准时间)
---

local MdBase = require("Ikun.Module.MdBase")
local ConMgr = require("Content.ConMgr")
local class = require("Util.Class.class1")

---@class MdMgr
local MdMgr = class.class "MdMgr" : extends "MdBase" {
    MdName = "MdMgr",
    tbMd = {
        ConMgr = class.new"ConMgr"()
    },
    ctor = function(self) end,
    Init = function(self) end,
    Tick = function(self, DeltaTime) end,
}
---@private [override]
function MdMgr:Init()
    self.super.Init(self)
    for _, Md in pairs(self.tbMd) do
        Md:Init()
    end
end
---@private [override]
function MdMgr:Tick(DeltaTime)
    for _, Md in pairs(self.tbMd) do 
        Md:Tick(DeltaTime)
    end
end