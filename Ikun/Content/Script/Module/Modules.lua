
---
---@brief   Modules
---@author  zys
---@data    Fri Nov 07 2025 16:16:52 GMT+0800 (中国标准时间)
---

---@class Modules
---@field _GameWorld UWorld
local Modules = class.class 'Modules' {}

---@public
function Modules:ctor(World)
    self._GameWorld = World
    
end

return Modules