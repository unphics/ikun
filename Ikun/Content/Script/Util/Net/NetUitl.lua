net_util = {}

net_util.b_svr = nil

---@public
---@return boolean
net_util.is_server = function(world)
    return net_util.b_svr
end

---@public
---@return boolean
net_util.is_client = function(world)
    return net_util.b_svr
end

return net_util