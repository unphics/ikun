
---
---@brief   Modules
---@author  zys
---@data    Fri Nov 07 2025 16:16:52 GMT+0800 (中国标准时间)
---

require('Module/GameLevel/GameLevelMgr')
require('Module/GameSession/GameSession')

---@class Modules
---@field GameLevelMgr GameLevelMgr
---@field GameSession GameSession
---@field _GameWorld UWorld
local Modules = class.class 'Modules' {}

---@public
function Modules:ctor()
    self.GameLevelMgr = class.new'GameLevelMgr'()
    self.GameSession = class.new'GameSession'()
end

---@override
function Modules:tick(DeltaTime)
    
end

return Modules