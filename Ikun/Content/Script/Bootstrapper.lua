
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 引导程序
--  File        : Bootstrapper.lua
--  Author      : zhengyanshuai
--  Date        : Thu Dec 18 2025 23:10:46 GMT+0800 (中国标准时间)
--  Description : 拉起Lua脚本中的一些基础架构
--  Warn        : 此文件的修改必须征得本人同意(全局变量增加要慎重)!!!
--  Todo        : 考虑重新设计封装
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

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

require('System/Ability/Core/Test')