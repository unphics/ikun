
---
---@brief   宇宙
---@author  zys
---@data    Tue Sep 23 2025 00:57:01 GMT+0800 (中国标准时间)
---

require('Content/Area/Site')
require('Content/Area/Location')
require('Content/Area/Landform')
require("Content/Area/Star")

---@class CosmosClass
---@field _tbStar StarClass[]
local CosmosClass = class.class "CosmosClass" {
    ctor = function()end,
    TickCosmos = function()end,
    InitAllStar = function() end,
    _tbStar = {},
}

---@override
function CosmosClass:ctor()
    self._tbStar = {}

    gameinit.registerinit(gameinit.ring.zero, self, self.InitAllStar)
end

---@override
function CosmosClass:TickCosmos(DeltaTime)
    for _, star in ipairs(self._tbStar) do
        star:TickStar(DeltaTime)
    end
end

---@public [Init] 初始化所有星球
function CosmosClass:InitAllStar()
    local allStarConfig = ConfigMgr:GetConfig('Star')
    for id, config in pairs(allStarConfig) do
        local star = class.new'StarClass'(id, config.StarName) ---@as StarClass
        table.insert(self._tbStar, star)
    end
end

---@public [Pure]
---@return StarClass
function CosmosClass:GetStar()
    --- 现在只有一个星球
    return self._tbStar[1]
end

return CosmosClass