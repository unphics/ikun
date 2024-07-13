--[[
    @brief 游戏内容
]]

local class = require("Util.Class.class1")
require("Content.Will.WillMgr")
require("Content.Cosmos.Cosmos")

class.class "ConMgr" : extends "MdBase" {
    MdName = 'ConMgr',
    tbCon = {
        WillMgr = class.new "WillMgr"(),
        Cosmos = class.new "Cosmos"(),
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