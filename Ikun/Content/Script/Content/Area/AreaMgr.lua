---
---@brief 自然区划管理器
---

require("Content.Area.Cosmos")

---@class AreaMgr: MdBase
local AreaMgr = class.class "AreaMgr" : extends "MdBase" {
--[[public]]
    ctor = function() end,
    GetStar = function() end,
    Tick = function()end,
--[[private]]
    Cosmos = nil,
}
function AreaMgr:ctor()
    self.Cosmos = class.new"Cosmos"()
end
function AreaMgr:GetStar()
    ---@todo 现在只有一个星球
    return self.Cosmos.tbStar[1]
end
function AreaMgr:Tick(DeltaTime)
    self.Cosmos:Tick(DeltaTime)
end