
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 时间工具
--  File        : TimeLib.lua
--  Author      : zhengyanshuai
--  Date        : Sat Jan 03 2026 20:28:06 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local log = require("Core/Log/log")
local ffi = require("ffi")

ffi.cdef[[
    int64_t GetUnixTimestampMS();
]]

local lib = nil

local LoadLib = function()
    local status, result = pcall(ffi.load, "UnrealEditor-LuaENet")
    if status then
        lib = result
    else
        status, result = pcall(ffi.load, "UnrealEditor-LuaENet-Win64-DebugGame")
        if status then
            lib = result
        end
    end
    
    if not lib then
        log.fatal("Failed to load Library [UnrealEditor-LuaENet]!")
    end
end

LoadLib()

---@class TimeLib
---@field UnixTimestampMs number?
local TimeLib = {}

TimeLib.UnixTimestampMs = nil

function TimeLib.TickTimeLib()
    TimeLib.UnixTimestampMs = nil
end

---@return number
function TimeLib.GetTimestampMS()
    if not TimeLib.UnixTimestampMs then
        TimeLib.UnixTimestampMs = tonumber(lib.GetUnixTimestampMS()) or -1
    end
    return TimeLib.UnixTimestampMs ---@as number
end

---@return number
function TimeLib.GetTimestampSec()
    return TimeLib.GetTimestampMS() / 1000
end

return TimeLib