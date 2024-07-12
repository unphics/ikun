net_util = {}

---@public
---@return boolean
net_util.is_server = function()
    return UE.UGameplayStatics.GetPlayerController(world_util.GameWorld, 0):HasAuthority()
end

---@public
---@return boolean
net_util.is_client = function()
    return not UE.UGameplayStatics.GetPlayerController(world_util.GameWorld, 0):HasAuthority()
end

return net_util