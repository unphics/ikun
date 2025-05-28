
---
---@brief Lua开发中常用的数学工具方法
---@author zys
---@data Sun May 04 2025 14:18:42 GMT+0800 (中国标准时间)
---

local math_util = {}

---@param float number
math_util.is_zero = function(float)
    return (float < 0.001) and (float > -0.001)
end

return math_util