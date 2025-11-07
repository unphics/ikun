
---
---@brief   游戏关卡管理
---@author  zys
---@data    Fri Nov 07 2025 01:31:01 GMT+0800 (中国标准时间)
---

---@class GameLevelMgr
---@field _GameWorld UWorld
local GameLevelMgr = class.class 'GameLevelMgr' {}

---@public
---@param World UWorld
function GameLevelMgr:ctor(World)
    self._GameWorld = World.GetWorld and World:GetWorld() or World
end

---@public 初始化游戏关卡
function GameLevelMgr:InitLevel()
    if not self:_CheckLevel() then
        self:_OpenEntryLevel()
    end
end

---@private 检测当前是正确的关卡
---@return boolean
function GameLevelMgr:_CheckLevel()
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

---@private 打开入口关卡
function GameLevelMgr:_OpenEntryLevel()
    UE.UGameplayStatics.OpenLevel(self._GameWorld, 'EntryMap', true, "Client")
end

return GameLevelMgr