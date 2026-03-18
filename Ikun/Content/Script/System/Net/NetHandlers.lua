

local NetSystem = require("NetSystem")
local Protocols = require("Protocols")
local log = require("Core/Log/log")

local NetHandlers = {}

-- 处理心跳 
NetSystem:Register(Protocols.MSG.PING, function(peer, data, header)
    log.info("NetHandlers", "Received Ping from " .. tostring(peer))
    
    -- 如果是服务器，收到 Ping 立刻回一个 Pong
    if NetSystem.IsServer then
        NetSystem:Send(peer, Protocols.MSG.PONG, data, false)
    end
end)

-- 处理登录
NetSystem:Register(Protocols.MSG.LOGIN_REQ, function(peer, data, header)
end)

-- 处理移动同步(高频包)
NetSystem:Register(Protocols.MSG.PLAYER_MOVE, function(peer, data, header)
end)