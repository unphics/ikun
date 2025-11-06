
---
---@brief   初始化地图
---@author  zys
---@data    Fri Nov 07 2025 01:31:01 GMT+0800 (中国标准时间)
---

---@class GameMap
---@field _GameWorld UWorld
local GameMap = class.class 'GameMap' {}

---@public
---@param World UWorld
function GameMap:ctor(World)
    self._GameWorld = World.GetWorld and World:GetWorld() or World
end

---@public 检测当前是正确的地图
---@return boolean
function GameMap:CheckMap()
    if not obj_util.is_valid(self._GameWorld) then
        return false
    end
    if net_util.is_in_session(self._GameWorld) then
        return true
    end
    if self._GameWorld:GetName() == 'EntryMap' then
        return true
    end
    return false
end

return GameMap