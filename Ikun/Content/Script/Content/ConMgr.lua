---
---@brief 纯游戏内容管理器
---

require("Content.Will.WillMgr")
require("Content.Area.AreaMgr")

local ConMgr = class.class "ConMgr" : extends "MdBase" {
    MdName = 'ConMgr',
    tbCon = {
        WillMgr = class.new "WillMgr"(),
        AreaMgr = class.new "AreaMgr"(),
    },
    Init = function(self) end,
    Tick = function(DeltaTime) end
}
function ConMgr:Init()
    self.super.Init(self)
    for k, v in pairs(self.tbCon) do
        v:Init()
    end
end