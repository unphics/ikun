---
---@brief 宇宙
---

require("Content/Area/Star")
local StarConfig = require("Content/Area/Config/StarConfig")

---@class Cosmos: MdBase
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
function Cosmos:Tick(DeltaTime)
    for i, Star in ipairs(self.tbStar) do
        Star:Tick(DeltaTime)
    end
end
function Cosmos:InitAllStar()
    for i, cfg in ipairs(StarConfig) do
        local StarId = 100 + #self.tbStar + 1
        local Star = class.new "Star" (StarId, cfg.Name) ---@type Star
        table.insert(self.tbStar, Star)
    end
end
function Cosmos:Reincarnate()
    local random = math.random(1, #self.tbStar)
end

function Cosmos:GetStar()
    --- 现在只有一个星球
    return self.tbStar[1]
end