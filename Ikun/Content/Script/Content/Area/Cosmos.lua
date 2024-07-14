require("Content/Area/Star")
local CosmosCfg = require("Content/Area/Config")

class.class "Cosmos" : extends "MdBase" {
    tbStar = {},
    ctor = function(self)
        self:InitAllStar()
    end,
    Init = function(self)
    end,
    ---@private
    InitAllStar = function(self)
        for i, cfg in ipairs(CosmosCfg.Star) do
            local star = class.new "Star" (cfg.Name)
            table.insert(self.tbStar, star)
        end
    end,
    ---@public 玩家随机投胎
    Reincarnate = function(self)
        local random = math.random(1, #self.tbStar)
    end
}