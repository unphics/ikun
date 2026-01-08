
---
---@brief   引导程序
---@author  zys
---@data    Thu Dec 18 2025 23:10:46 GMT+0800 (中国标准时间)
---

local ffi = require ("ffi") ---@type ffilib
local log = require('Core/Log/log') ---@type log

log.info("========================================")
log.info("[Check] Lua Version Check:")
log.info("Global _VERSION: " .. tostring(_VERSION))
if _G.jit then
    log.info("✅ JIT Enabled!")
    log.info("   - Version: " .. tostring(_G.jit.version))
    log.info("   - Arch:    " .. tostring(_G.jit.arch))
    log.info("   - OS:      " .. tostring(_G.jit.os))
    -- 检查 JIT 编译器是否真的在工作
    if _G.jit.status() then
        log.info("   - Status:  Running (Optimizing code)")
    else
        log.info("   - Status:  OFF (Interpreter mode)")
    end
else
    log.info("❌ No JIT detected! You are running standard Lua.")
end
log.info("========================================")

--[[
require('Core/FFI/test')
--]]


_G.ffi = require ("ffi") ---@type ffilib
_G.log = require('Core/Log/log') ---@type log

require('SharedPCH')

require('System/Skill/Core/Test')