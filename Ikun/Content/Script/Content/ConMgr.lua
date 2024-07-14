--[[
    @brief 游戏内容
]]

require("Content.Will.WillMgr")
require("Content.Area.AreaMgr")

class.class "ConMgr" : extends "MdBase" {
    MdName = 'ConMgr',
    tbCon = {
        WillMgr = class.new "WillMgr"(),
        AreaMgr = class.new "AreaMgr"(),
    },
    Init = function(self)
        self.super.Init(self)
        for k, v in pairs(self.tbCon) do
            v:Init()
        end
    end,
    Tick = function(DeltaTime)

    end
}