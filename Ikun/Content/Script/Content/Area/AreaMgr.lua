--[[
    @brief 地域管理
]]
require("Content.Area.Cosmos")

class.class "AreaMgr" : extends "MdBase" {
    Cosmos = nil,
    ctor = function(self)
        self.Cosmos = class.new"Cosmos"()
    end,
}