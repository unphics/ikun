
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

local log = require("Core/Log/log")

-- 初始化点: 定义了所有需要初始化的模块/系统
---@diagnostic disable-next-line duplicate-type
---@enum InitPoint
local InitPoint = {
    InitStar = "InitStar",
    InitQuest = "InitQuest",
    InitLoc = "InitLoc",
    InitSite = "InitSite",
    InitBagComp = "InitBagComp",
    InitRole = "InitRole",
    OpenDefaultUI = "OpenDefaultUI",
    InitFinish = "InitFinish",
}

-- 初始化环
---@diagnostic disable-next-line duplicate-type
---@class InitRing
local InitRing = {}

---@type InitPoint[]
InitRing.EnvInit = {
    InitPoint.InitStar,
    InitPoint.InitQuest,
}
---@type InitPoint[]
InitRing.GameInst_ReceiveInit = {
    InitPoint.InitLoc,
}
---@type InitPoint[]
InitRing.PC_BeginPlay = {
    InitPoint.InitSite,
}
---@type InitPoint[]
InitRing.PC_BeginPlay_Delay_1 = {
    InitPoint.InitRole,
    InitPoint.OpenDefaultUI,
}
---@type InitPoint[]
InitRing.PC_BeginPlay_Delay_2 = {
    InitPoint.InitBagComp,
    InitRing.InitFinish,
}

---@diagnostic disable-next-line duplicate-type
---@class InitPointData
---@field Obj table?
---@field Callback fun(self:table)?

---@diagnostic disable-next-line duplicate-type
---@class GameInit
---@field private _InitPointInfos table<InitPoint, InitPointData[]>
---@field private _InitedMark table<InitPoint, boolean>
local GameInit = {}
GameInit._InitPointInfos = {}
GameInit._InitedMark = {}
GameInit.InitRing = InitRing
GameInit.InitPoint = InitPoint

-- 创建回调表
for _, keys in pairs(InitRing) do
    ---@param key InitPoint
    for _, key in ipairs(keys) do
        GameInit._InitPointInfos[key] = {}
    end
end

for key in pairs(InitPoint) do
    GameInit._InitedMark[key] = false
end

---@public
---@param InPoint InitPoint
---@param InObject table?
---@param InCallback fun(self?: table)
GameInit.RegisterInit = function(InPoint, InObject, InCallback)
    local infos = GameInit._InitPointInfos[InPoint]
    if not infos then
        log.warn(log.key.gameinit, "RegisterInit failed: ring not found", InPoint)
        return
    end

    table.insert(infos, {obj = InObject, callback = InCallback})
    
    if GameInit._InitedMark[InPoint] then
        ---@todo 优化掉这个
        InCallback(InObject)
    end
end

---@public
---@param InRing InitPoint[]
GameInit.BroadcastInit = function(InRing)
    if type(InRing) ~= "table" then
        log.error(log.key.gameinit, "BroadcastInit failed: InRing is not a table")
        return
    end

    for _, key in ipairs(InRing) do
        local infos = GameInit._InitPointInfos[key]
        log.info(log.key.gameinit, "BroadcastInit", key)
        ---@param info any
        for _, info in pairs(infos) do
            if info and type(info) == "table" and info.callback and info.obj then
                info.callback(info.obj)
            end
        end
        GameInit._InitedMark[key] = true
    end
end

GameInit.RegisterInit(InitPoint.InitFinish, nil, function()
    -- for _, ele in pairs(GameInit._InitedMark) do
    --     if not ele then
    --         return false
    --     end
    -- end
    log.mark(log.key.gameinit, "All init finished !")
end)

return GameInit