
---
---@brief   游戏会话
---@author  zys
---@data    Thu Nov 06 2025 15:17:47 GMT+0800 (中国标准时间)
---

---@class GameSession
local GameSession = class.class 'GameSession' {}

---@public
function GameSession:ctor()
end

---@public 创建会话
---@param InPC APlayerController
---@param PlayerCount integer
---@param bUseLan boolean
---@param Callback fun()
function GameSession:CreateSession(InPC, PlayerCount, bUseLan, Callback)
    local proxy = UE.UCreateSessionCallbackProxy.CreateSession(InPC, InPC, PlayerCount, bUseLan)
    proxy.OnSuccess:Add(InPC, Callback)
    proxy.OnFailure:Add(InPC, function()
        log.error('GameSession:CreateSession', 'Failed to create session!!!')
    end)
    proxy:Activate()
end

---@class SessionInfo
---@field SessionResult FBlueprintSessionResult
---@field SessionName string
---@field CurPlayerNum integer
---@field MaxPlayerNum integer
---@field PingMs integer

---@public 搜寻会话
---@param InPC APlayerController
---@param bUseLan boolean
---@param Callback fun(tbInSessionResult: SessionInfo[])
function GameSession:FindSession(InPC, bUseLan, Callback)
    local proxy = UE.UFindSessionsCallbackProxy.FindSessions(InPC, InPC, 100, bUseLan)
    proxy.OnSuccess:Add(InPC, function(_, InSessionResults)
        local infos = {} ---@type SessionInfo[]
        for i =  1, InSessionResults:Length() do
            local sessionResult = InSessionResults:Get(i) ---@type FBlueprintSessionResult
            local info = {} ---@type SessionInfo
            info.SessionResult = sessionResult
            info.SessionName = UE.UFindSessionsCallbackProxy.GetServerName(sessionResult)
            info.CurPlayerNum = UE.UFindSessionsCallbackProxy.GetCurrentPlayers(sessionResult)
            info.MaxPlayerNum = UE.UFindSessionsCallbackProxy.GetMaxPlayers(sessionResult)
            info.PingMs = UE.UFindSessionsCallbackProxy.GetPingInMs(sessionResult)
            table.insert(infos, info)
        end
        Callback(infos)
    end)
    proxy.OnFailure:Add(InPC, function()
        log.error('GameSession:FindSession', 'Failed to find session!!!')
    end)
    proxy:Activate()
end

---@public 加入会话
---@param InPC APlayerController
---@param SessionResult FBlueprintSessionResult
function GameSession:JoinSession(InPC, SessionResult)
    local proxy = UE.UJoinSessionCallbackProxy.JoinSession(InPC, InPC, SessionResult)
    proxy.OnSuccess:Add(InPC, function()
        log.info('GameSession:JoinSession', 'Succeed to join!')
    end)
    proxy.OnFailure:Add(InPC, function()
        log.info('GameSession:JoinSession', 'Failed to join!!!')
    end)
    proxy:Activate()
end

return GameSession