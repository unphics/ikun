
---
---@brief   GameInstance,一些全局的东西在这里引用
---@author  zys
---@data    Fri May 30 2025 22:37:34 GMT+0800 (中国标准时间)
---

require('Start')
require('Bootstrapper')
local UnLuaClass = require("Core/UnLua/Class")
local log = require("Core/Log/log")
local GameInit = require("Core/Init/GameInit")

---@class BP_GameInst: BP_GameInst_C
local BP_GameInst = UnLuaClass()

function BP_GameInst:ReceiveInit()
    self.Overridden.ReceiveInit(self)
    -- 此处是客户端和服务器最早启动的地方, 因此可以在这里做一些初始化全局或者静态的东西
    log.mark(log.key.ueinit, "BP_GameInstanceBase:ReceiveInit()", "✅")

    UE.UKismetSystemLibrary.ExecuteConsoleCommand(self, 't.MaxFPS 1000', nil)
    UE.UKismetSystemLibrary.ExecuteConsoleCommand(self, 'stat FPS', nil)
    GameInit.BroadcastInit(GameInit.InitRing.GameInst_ReceiveInit)
end

---@override 运行时新地图加载前调用
function BP_GameInst:OnPreLoadMap(InURL)
end

---@override 地图加载后, 所有Actor加载前调用
function BP_GameInst:ReceiveOnActorsInitialized()
    log.mark(log.key.sceneinit, "BP_GameInst:ReceiveOnActorsInitialized", "✅")
    GameInit.BroadcastInit(GameInit.InitRing.GameInst_ScenePreInit)
end

---@override
function BP_GameInst:ReceiveOnWorldChanged(OldWorld, NewWorld)
    do
        local newWorldName = NewWorld and NewWorld:GetName()
        local type = NewWorld and UE.UIkunFnLib.GetWorldType(NewWorld)
        log.info('BP_GameInst:ReceiveOnWorldChanged()', OldWorld, NewWorld, newWorldName, type)
    end
end

---@override 地图加载完, 所有Actor都加载结束前调用
function BP_GameInst:OnWorldBeginPlay()
    log.mark(log.key.sceneinit, "BP_GameInst:OnWorldBeginPlay", "✅")
    GameInit.BroadcastInit(GameInit.InitRing.GameInst_ScenePostInit)
end

---@override 运行时新地图加载后, 地图完全加载完, 所有Actor都加载结束后调用, 比OnWorldBeginPlay晚
function BP_GameInst:OnPostLoadMap(InWorld)
end

return BP_GameInst