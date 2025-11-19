
---
---@brief   UE网络相关的工具方法
---@author  zys
---@data    Sun May 04 2025 14:18:04 GMT+0800 (中国标准时间)
---

---@class net_util
local net_util = {}

---@public 判断是服务端
---@return boolean
net_util.is_server = function(InWorld)
    return UE.UKismetSystemLibrary.IsServer(InWorld)
end

---@public 判断是客户端
---@return boolean
net_util.is_client = function(InWorld)
    return not UE.UKismetSystemLibrary.IsServer(InWorld)
end

---@public 格式化打印当前的CS描述
---@return string
net_util.print = function(InWorld)
    return net_util.is_server(InWorld) and '<Net:Server>' or '<Net:Client>'
end

---@public 判断在一个会话中
---@return boolean
net_util.is_in_session = function(InWorld, Name)
    Name = Name or "None"
    return UE.UIkunFnLib.IsInSession(InWorld, Name)
end

---@public 客户端获取玩家Character
net_util.client_get_player_chr = function(InWorld)
    if net_util.is_server(InWorld) then
        log.error('Must be client!')
        return
    end
    return UE.UGameplayStatics.GetPlayerCharacter(InWorld, 0)
end

return net_util