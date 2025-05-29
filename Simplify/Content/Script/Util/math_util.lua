
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

math_util.point_to_line_dist_2d = function(px, py, x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = x2 - x1
    local numerator = math.abs(dx * (y1 - py) - (x1 - px) * dy)
    local denominator = math.sqrt(dx * dx + dy * dy)
    return numerator / denominator
end

return math_util