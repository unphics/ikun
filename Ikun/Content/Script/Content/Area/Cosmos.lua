
---
---@brief   宇宙
---@author  zys
---@data    Tue Sep 23 2025 00:57:01 GMT+0800 (中国标准时间)
---

require('Content/Area/Site')
require('Content/Area/Location')
require('Content/Area/Landform')
require("Content/Area/Star")

local StarConfig = require("Content/Area/Config/StarConfig")

---@class Cosmos: MdBase
---@field _tbStar StarClass[]
local Cosmos = class.class "Cosmos" : extends "MdBase" {
    ctor = function() end,
    Init = function() end,
    Tick = function()end,
    _InitAllStar = function() end,
    _tbStar = {},
}

---@override
function Cosmos:ctor()
    self._tbStar = {}

    self:_InitAllStar()
end

---@override
function Cosmos:Tick(DeltaTime)
    for i, star in ipairs(self._tbStar) do
        star:Tick(DeltaTime)
    end
end

---@private 初始化所有星球
function Cosmos:_InitAllStar()
    for i, cfg in ipairs(StarConfig) do
        local starId = 100 + #self._tbStar + 1
        local star = class.new "StarClass" (starId, cfg.Name) ---@type StarClass
        table.insert(self._tbStar, star)
    end
end

---@public [Pure]
---@return StarClass
function Cosmos:GetStar()
    --- 现在只有一个星球
    return self._tbStar[1]
end