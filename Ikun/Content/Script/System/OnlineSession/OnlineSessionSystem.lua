
---
---@brief   在线会话系统
---@author  zys
---@data    Thu Nov 06 2025 15:17:47 GMT+0800 (中国标准时间)
---

---@class OnlineSessionSystem
local OnlineSessionSystem = class.class 'OnlineSessionSystem' {}

---@public
---@param World UWorld
function OnlineSessionSystem.OpenEntryMap(World)
    UE.UGameplayStatics.OpenLevel(World, 'EntryMap', true, "Client")
end

return OnlineSessionSystem