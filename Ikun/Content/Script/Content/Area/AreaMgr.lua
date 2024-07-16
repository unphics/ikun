--[[
    @brief 地域管理
]]
require("Content.Area.Cosmos")

class.class "AreaMgr" : extends "MdBase" {
    Cosmos = nil,
    ctor = function(self)
        self.Cosmos = class.new"Cosmos"()
    end,
    GetStar = function(self)
        -- TODO
        return self.Cosmos.tbStar[1]
    end
}