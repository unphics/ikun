
---
---@brief   UE网络相关的工具方法
---@author  zys
---@data    Sun May 04 2025 14:18:04 GMT+0800 (中国标准时间)
---

---@class net_util
local net_util = {}

---@public
---@return boolean
net_util.is_server = function(World)
    World = World or world_util.World
    return UE.UKismetSystemLibrary.IsServer(World)
end

---@public
---@return boolean
net_util.is_client = function(World)
    World = World or world_util.World
    return not UE.UKismetSystemLibrary.IsServer(World)
end

---@public
net_util.client_get_player_chr = function(World)
    if net_util.is_server(World) then
        log.error('Must be client!')
        return
    end
    return UE.UGameplayStatics.GetPlayerCharacter(World, 0)
end

---@public
---@return string
net_util.print = function(world)
    return net_util.is_server(world) and '<Net:Server>' or '<Net:Client>'
end

return net_util