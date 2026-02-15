
--[[
-- -----------------------------------------------------------------------------
--  Brief       : FFI库
--  File        : ffistate.lua
--  Author      : zhengyanshuai
--  Date        : Sun Feb 15 2026 14:33:31 GMT+0800 (中国标准时间)
--  Description : 一些luajitffi的方法封装
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local log = require("Core/Log/log")
local ffi = require("ffi") ---@type ffilib

local ffistate = {}

local function printf(fmt, ...)
    log.info_fmt("[LuaJit - FFIState] "..fmt, ...)
end

function ffistate.PrintState()
    printf("[Check] Lua Version Check: _VERSION = %s", _VERSION)
    if _G.jit then
        printf("✅ JIT Enabled!")
        printf("   - Version: %s", _G.jit.version)
        printf("   - Arch:    %s", _G.jit.arch)
        printf("   - OS:      %s", _G.jit.os)
        -- 检查 JIT 编译器是否真的在工作
        if _G.jit.status() then
            printf("   - Status:  Running (Optimizing code)")
        else
            printf("   - Status:  OFF (Interpreter mode)")
        end
    else
        printf("❌ No JIT detected! You are running standard Lua.")
    end
end

-- ffistate.PrintState()

return ffistate