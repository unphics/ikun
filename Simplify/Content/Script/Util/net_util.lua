
---
---@brief UE网络相关的工具方法
---@author zys
---@data Sun May 04 2025 14:18:04 GMT+0800 (中国标准时间)
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
    ---@todo 多人的时候记得判断一下客户端PlayerIndex=0准确与否
    return UE.UGameplayStatics.GetPlayerCharacter(World, 0)
end

return net_util