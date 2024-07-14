require("Content.Star.Star")
local CosmosCfg = require("Content/Cosmos/Config")

class.class "Cosmos" : extends "MdBase" {
    tbStar = {},
    ctor = function(self)
        self.MdName = "Cosmos"
        self:InitCosmos()
    end,
    Init = function(self) end,
    ---@private
    InitCosmos = function(self)
        for i, cfg in ipairs(CosmosCfg.Star) do
            local star = class.new "Star" (cfg.Name)
            table.insert(self.tbStar, star)
        end
        self:Reincarnate()
        self:Reincarnate()
        self:Reincarnate()
    end,
    ---@public 玩家随机投胎
    Reincarnate = function(self)
        local random = math.random(1, #self.tbStar)
        
    end
}