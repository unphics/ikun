---
---@brief 纯逻辑模块的基类
---

---@class MdBase
local MdBase = class.class "MdBase" {
    ctor = function() end,
    Init = function() end,
    Uninit = function() end,
    Tick = function(DeltaTime) end,
}
function MdBase:ctor()
end
function MdBase:Init()
end
function MdBase:Uninit()
end
function MdBase:Tick(DeltaTime)
end