---@class net_util
local net_util = {}

---@public
---@return boolean
net_util.is_server = function(World)
    World = World or world_util.GameWorld
    return UE.UKismetSystemLibrary.IsServer(World)
end

---@public
---@return boolean
net_util.is_client = function(World)
    World = World or world_util.GameWorld
    return not UE.UKismetSystemLibrary.IsServer(World)
end

return net_util