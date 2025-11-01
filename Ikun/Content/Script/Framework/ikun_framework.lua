
---
---@biref   其实承担Core的作用
---@author  zys
---@data    Sat Nov 01 2025 00:16:52 GMT+0800 (中国标准时间)
---


---@class ikf
---@field class class
---@field log log
local ikf = {}

---@param setting ikf_setting
ikf.init_core = function(setting)
    ikf.setting = setting
    ikf.math_util = require( setting.ikf_path..'/util/math_util')
    ikf.table_util = require(setting.ikf_path..'/util/table_util')
    ikf.str_util = require(setting.ikf_path..'/util/str_util')
    
    ikf.msg_bus = require(setting.ikf_path..'/core/msg/msg_bus')
    ikf.class = require(setting.ikf_path..'/core/class/class')(ikf)
    ikf.log = require(setting.ikf_path..'/core/log/log')(ikf)

    ikf.log.error('\n======================================================================================================================================================\n=================================================================='..'ikf'..'==================================================================\n======================================================================================================================================================')
end

return ikf