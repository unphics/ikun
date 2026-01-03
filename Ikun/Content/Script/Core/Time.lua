
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

local function GetTimestampMS()
    return tonumber(lib.GetUnixTimestampMS())
end

local function GetTimestampSec()
    return GetTimestampMS() / 1000
end

return {
    GetTimestampMS = GetTimestampMS,
    GetTimestampSec = GetTimestampSec,
}