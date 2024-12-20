---
---@brief 宇宙
---

require("Content/Area/Star")
local CosmosCfg = require("Content/Area/Config")

---@class Cosmos
---@field tbStar Star[]
local Cosmos = class.class "Cosmos" : extends "MdBase" {
--[[public]]
    ctor = function() end,
    Init = function() end,
    Reincarnate = function() end, -- 玩家随机投胎
    Tick = function()end,
--[[private]]
    InitAllStar = function() end, -- 初始化所有星球
    tbStar = {},
}
function Cosmos:ctor()
    self:InitAllStar()
end
function Cosmos:InitAllStar()
    for i, cfg in ipairs(CosmosCfg.Star) do
        local star = class.new "Star" (cfg.Name)
        table.insert(self.tbStar, star)
    end
end
function Cosmos:Reincarnate()
    local random = math.random(1, #self.tbStar)
end
function Cosmos:Tick(DeltaTime)
    for i, Star in ipairs(self.tbStar) do
        Star:Tick(DeltaTime)
    end
end