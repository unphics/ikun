
---
---@biref   其实承担core的作用
---@author  zys
---@data    Sat Nov 01 2025 00:16:52 GMT+0800 (中国标准时间)
---


---@class ikf
---@field setting ikf_setting
---@field math_util math_util
---@field table_util table_util
---@field str_util str_util
---@field log log
---@field class class
---@field msg_bus msgbus
ikf = {}

---@param setting ikf_setting
ikf.init_core = function(setting)
    ikf.setting = setting
    -- ikf.math_util = require( setting.ikf_path..'/util/math_util')
    -- ikf.table_util = require(setting.ikf_path..'/util/table_util')
    -- ikf.str_util = require(setting.ikf_path..'/util/str_util')
    
    ikf.log = require(setting.ikf_path..'/core/log/log')
    ikf.class = require(setting.ikf_path..'/core/class/class')
    ikf.init = require(setting.ikf_path..'/init/init')

    ikf.log.error('\n======================================================================================================================================================\n=================================================================='..'ikf'..'==================================================================\n======================================================================================================================================================')
end

return ikf