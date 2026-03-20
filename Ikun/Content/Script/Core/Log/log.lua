
--[[
-- -----------------------------------------------------------------------------
--  Brief       : log
--  File        : Log.lua
--  Author      : zhengyanshuai
--  Date        : Sun May 04 2025 14:19:28 GMT+0800 (中国标准时间)
--  Description : 游戏日志
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local sys_print = _G.IkunLog
local sys_warn = _G.IkunWarn
local sys_error = _G.IkunError
local string = _G.string
local debug_traceback = _G.debug.traceback
local select = _G.select

-- 内部辅助：处理字符串格式化
local function fmt_out(fmt, ...)
    if select("#", ...) == 0 then
        return tostring(fmt)
    end
    local status, result = pcall(string.format, fmt, ...)
    return status and result or string.format("LogFormatError: result=[%s] | raw=[%s]", tostring(result), tostring(fmt))
end

---@class log
---@field key logkeys
local log = {}

---@public 开发期临时高亮日志
function log.dev(...)
    sys_error("[DEV]", ...)
end

---@public 开发期占位
function log.todo(...)
    sys_error("[TODO]", ...)
end

---@public 关键时机标记
function log.mark(...)
    sys_warn("[MARK]", ...)
end

---@public 基础日志
function log.log(...)
    sys_print("[LOG]", ...)
end
---@public 格式化日志
function log.log_fmt(fmt, ...)
    log.log(fmt_out(fmt, ...))
end

---@public 调试信息
function log.debug(...)
    sys_print("[DEBUG]", ...)
end
---@public 格式化调试信息
function log.debug_fmt(fmt, ...)
    log.debug(fmt_out(fmt, ...))
end

---@public 关键节点信息
function log.info(...)
    sys_print("[INFO]", ...)
end
---@public 格式化关键节点信息
function log.info_fmt(fmt, ...)
    log.info(fmt_out(fmt, ...))
end

---@public 警告信息
function log.warn(...)
    sys_warn("[WARN]", ...)
end
---@public 格式化警告信息
function log.warn_fmt(fmt, ...)
    log.warn(fmt_out(fmt, ...))
end

---@public 错误信息
function log.error(...)
    sys_error("[ERROR]", ...)
end
---@public 格式化错误信息
function log.error_fmt(fmt, ...)
    log.error(fmt_out(fmt, ...))
end

---@public 致命错误（带堆栈）
function log.fatal(...)
    sys_error("[FATAL]", ..., debug_traceback("", 2)) -- 使用level_2可以让堆栈直接从调用log.fatal的那个逻辑文件开始显示，排查问题更直观
end
---@public 格式化致命错误
function log.fatal_fmt(fmt, ...)
    log.fatal(fmt_out(fmt, ...))
end

---@class logkeys
local keys = {
    luainit     = '[Lua初始化]',
    ueinit      = '[UE初始化]',
    gameinit    = '[游戏初始化]',
    roleinit    = '[角色初始化]',
    repos       = '[射手站位调整]',
    lich02boom  = '[Lich二技能]',
    beha        = '[行为选择]',
    support     = '[支援]',
    abp         = '[动画蓝图]',
    archer01    = '[弓箭手一技能]',
    sceneinit   = '[场景初始化]',
    chat        = '[对话]', -- 对话界面, 对话模块, 交互模块(任务是否也同)
    item        = '[物品]',
}

log.key = keys

return log