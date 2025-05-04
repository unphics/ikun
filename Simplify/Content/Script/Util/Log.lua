
---
---@brief UELua开发的Log工具
---@author zys
---@data Sun May 04 2025 14:19:28 GMT+0800 (中国标准时间)
---

---@class log
---@field tb_log table<string, number>
---@field tb_warn table<string, number>
---@field tb_error table<string, number>


local log = {}

---@param tag string
---@param vararg string
function log.log(...)
    print( ...)
end

---@param tag string
---@param vararg string
function log.warn(...)
    UnLua.LogWarn(...)
end

---@param tag string
---@param vararg string
function log.error(...)
    UnLua.LogError(...)
end

---@param tag string
---@param vararg string
function log.dev(...)
    UnLua.LogError(...)
end

return log