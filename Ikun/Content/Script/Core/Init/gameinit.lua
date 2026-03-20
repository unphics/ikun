
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 初始化时序管理
--  File        : GameInit.lua
--  Author      : zhengyanshuai
--  Date        : Tue Sep 23 2025 11:13:55 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local log = require('Core/Log/log')

-- 初始化环: 定义了所有需要初始化的模块/系统, 每一个环代表一个初始化点
---@diagnostic disable-next-line duplicate-type
---@enum InitRing
local InitRing = {
    InitStar = 'InitStar',
    InitQuest = 'InitQuest',
    InitLoc = 'InitLoc',
    InitSite = 'InitSite',
    InitBagComp = 'InitBagComp',
    InitRole = 'InitRole',
    OpenDefaultUI = 'OpenDefaultUI',
}

-- 触发初始化的流程组
---@diagnostic disable-next-line duplicate-type
---@class InitGroup
---@field EnvInit InitRing[]
---@field GamemodeInit InitRing[]
---@field PlayerControllerInit InitRing[]
---@field PlayerControllerInit_Delay_1 InitRing[]
---@field PlayerControllerInit_Delay_2 InitRing[]
local InitGroup = {
    EnvInit = {
        InitRing.InitStar,
        InitRing.InitQuest,
    },
    GamemodeInit = {
        InitRing.InitLoc,
    },
    PlayerControllerInit = {
        InitRing.InitSite,
    },
    PlayerControllerInit_Delay_1 = {
        InitRing.InitRole,
        InitRing.OpenDefaultUI,
    },
    PlayerControllerInit_Delay_2 = {
        InitRing.InitBagComp,
    }
}

---@diagnostic disable-next-line duplicate-type
---@class GameInit
---@field private _InitRings table
local GameInit = {}
GameInit._InitRings = {}
GameInit.InitGroup = InitGroup
GameInit.InitRing = InitRing

-- 创建回调表
for _, keys in pairs(InitGroup) do
    for _, key in ipairs(keys) do
        GameInit._InitRings[key] = {}
    end
end

---@public
---@param callback fun(self: table)
GameInit.RegisterInit = function(InRing, InObject, InCallback)
    local infos = GameInit._InitRings[InRing]
    if not infos then
        return
    end

    table.insert(infos, {obj = InObject, callback = InCallback})
    
    if infos._inited then
        InCallback(InObject)
    end
end

---@public
GameInit.BroadcastInit = function(InGroup)
    for _, key in ipairs(InGroup) do
        local infos = GameInit._InitRings[key] ---@type table
        log.info(log.key.gameinit, 'BroadcastInit', key)

        ---@param info any
        for _, info in pairs(infos) do
            if info and type(info) == "table" and info.callback and info.obj then
                info.callback(info.obj)
            end
        end
        infos._inited = true
    end
end

return GameInit