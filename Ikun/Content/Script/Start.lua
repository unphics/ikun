
---
---@brief   双端LuaState最先加载
---@author  zys
---@data    Sat Apr 05 2025 14:07:42 GMT+0800 (中国标准时间)
---

ikf = require('Framework/ikun_framework') ---@type ikf
local setting = require('Framework/ikf_setting')
setting.sys_print = _G.IkunLog
setting.sys_warn = _G.IkunWarn
setting.sys_error = _G.IkunError
ikf.init_core(setting)

require('SharedPCH')