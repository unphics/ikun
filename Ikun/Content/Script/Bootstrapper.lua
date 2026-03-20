
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
local ffistate = require("Core/FFI/ffistate")
local Time = require('Core/Time')
local log = require('Core/Log/log') ---@type log
local DebugUtils = require('Utils/DebugUtils')

_G.log = require('Core/Log/log') ---@type log

local GameInit = require('Core/Init/GameInit')
require('SharedPCH')
GameInit.BroadcastInit(GameInit.groups.env_init)

require('System/Ability/Test')
local AbilitySystem = require('System/Ability/AbilitySystem')
function ENetTick(dt, world)
    AbilitySystem.Get():TickAbilitySystem(0.033)
end