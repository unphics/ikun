---
---@brief 纯游戏内容管理器
---

require("Content.Will.WillMgr")
require("Content.Area.AreaMgr")

local ConMgr = class.class "ConMgr" : extends "MdBase" {
    MdName = 'ConMgr',
    tbCon = nil,
    Init = function(self) end,
    Tick = function(DeltaTime) end
}
function ConMgr:ctor()
    self.tbCon = {
        WillMgr = class.new "WillMgr"(),
        AreaMgr = class.new "AreaMgr"(),
    }
end
function ConMgr:Init()
    class.MdBase.Init(self)
    for k, v in pairs(self.tbCon) do
        v:Init()
    end
end
function ConMgr:Tick(DeltaTime)
    for k, v in pairs(self.tbCon) do
        v:Tick(DeltaTime)
    end
end