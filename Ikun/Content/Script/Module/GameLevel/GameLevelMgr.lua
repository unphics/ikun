
---
---@brief   游戏关卡管理
---@author  zys
---@data    Fri Nov 07 2025 01:31:01 GMT+0800 (中国标准时间)
---

---@class GameLevelMgr
local GameLevelMgr = class.class 'GameLevelMgr' {}

---@public
function GameLevelMgr:ctor()
end

---@public 检测当前是正确的关卡
---@return boolean
function GameLevelMgr:CheckLevel(InWorld)
    if not obj_util.is_valid(InWorld) then
        return false
    end
    if net_util.is_in_session(InWorld) then
        return true
    end
    if InWorld:GetName() == 'EntryMap' then
        return true
    end
    return false
end

---@public 打开入口关卡
function GameLevelMgr:OpenEntryLevel(InWorld)
    UE.UGameplayStatics.OpenLevel(InWorld, 'EntryMap', true, "Client")
end

---@public 打开大世界游戏关卡
function GameLevelMgr:OpenGameLevel(InWorld)
    UE.UGameplayStatics.OpenLevel(InWorld, 'VillageMap', true, "Listen")
end

return GameLevelMgr