---
---@brief   模块管理器
---@desc    所有纯逻辑模块在这里拉起; MdMgr在GameInstance中被拉起
---@author  zys
---@data    Sun Dec 15 2024 11:27:34 GMT+0800 (中国标准时间)
---

local MdBase = require("Ikun.Module.MdBase")
local ConMgr = require("Content.ConMgr")

---@class MdMgr
local MdMgr = class.class "MdMgr" : extends "MdBase" {
--[[public]]
    ctor = function()end,
    Init = function()end,
    Tick = function(DeltaTime)end,
    MdName = "MdMgr",
    tbMd = nil,
}
---@private [override]
function MdMgr:Init()
    class.MdBase.Init(self)
    self.tbMd = {
        ConMgr = class.new"ConMgr"()
    }

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