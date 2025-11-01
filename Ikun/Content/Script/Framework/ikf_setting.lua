
---
---@brief   ikf setting
---@author  zys
---@data    Sat Nov 01 2025 19:34:43 GMT+0800 (中国标准时间)
---

---@class ikf_setting
---@field ikf_path string
---@field sys_print fun(...)
---@field sys_warn fun(...)
---@field sys_error fun(...)
local setting = {}

setting.ikf_path = 'Framework'
setting.logkey_path = setting.ikf_path..'/core/log/logkey'

setting.sys_print = function()end
setting.sys_warn = function()end
setting.sys_error = function()end


return setting