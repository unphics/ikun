
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 时间工具
--  File        : Time.lua
--  Author      : zhengyanshuai
--  Date        : Sat Jan 03 2026 20:28:06 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local ffi = require("ffi")

ffi.cdef[[
    int64_t GetUnixTimestampMS();
]]

local lib
local status, result = pcall(ffi.load, "UnrealEditor-LuaENet")
if status then
    lib = result
else
    status, result = pcall(ffi.load, "Ikun")
    if status then
        lib = result
    end
end

---@return number
local function GetTimestampMS()
    return tonumber(lib.GetUnixTimestampMS()) or -1
end

---@return number
local function GetTimestampSec()
    return GetTimestampMS() / 1000
end

return {
    GetTimestampMS = GetTimestampMS,
    GetTimestampSec = GetTimestampSec,
}