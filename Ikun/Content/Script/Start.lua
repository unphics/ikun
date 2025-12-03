
---
---@brief   双端LuaState最先加载
---@author  zys
---@data    Sat Apr 05 2025 14:07:42 GMT+0800 (中国标准时间)
---

_G.ffi = require 'ffi' ---@type ffilib

do -- 初始化ikf
    local setting = require('Framework/ikf_setting')
    setting.sys_print = _G.IkunLog
    setting.sys_warn = _G.IkunWarn
    setting.sys_error = _G.IkunError
    
    require('Framework/ikun_framework').init_core(setting)
end

require('SharedPCH')