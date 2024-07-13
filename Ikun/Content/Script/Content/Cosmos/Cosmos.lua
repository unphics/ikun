require("SharedPCH")
local CosmosCfg = require("Content/Star/Config")

class.class "Cosmos" : extends "MdBase" {
    tbStar = {},
    ctor = function(self)
        self.MdName = "Cosmos"
        self:InitCosmos()
    end,
    Init = function(self)
        
    end,
    ---@private
    InitCosmos = function(self)
        for i, cfg in ipairs(CosmosCfg.Star) do
            local star = {}
            star.Name = cfg.Name
            table.insert(self.tbStar, star)
        end
    end,
    ---@public 随机投胎
    Reincarnate = function(self)
        
    end
}