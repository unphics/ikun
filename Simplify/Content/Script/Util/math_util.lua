
---
---@brief Lua开发中常用的数学工具方法
---@author zys
---@data Sun May 04 2025 14:18:42 GMT+0800 (中国标准时间)
---

---@class math_util 数学库
local math_util = {}

---@public
---@param float number
math_util.is_zero = function(float)
    return (float < 0.001) and (float > -0.001)
end

---@public
math_util.point_to_line_dist_2d = function(px, py, x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    local numerator = math.abs(dx * (y1 - py) - (x1 - px) * dy)
    local denominator = math.sqrt(dx * dx + dy * dy)
    return numerator / denominator
end

---@public 钳制
---@param val number
---@param min number
---@param max number
---@return number
math_util.clamp = function(val, min, max)
    if val < min then
        return min
    end
    if val > max then
        return max
    end
    return val
end

---@public 插值
---@param a number
---@param b number
---@param alpha number
---@return number
math_util.lerp = function(a, b, alpha)
    return a + (b - a) * alpha
end

return math_util

--[[
---@param value number
---@param inMin number
---@param inMax number
---@param outMin number
---@param outMax number
---@return number
function MathUtil.MapRange(value, inMin, inMax, outMin, outMax)
    local ratio = (value - inMin) / (inMax - inMin)
    return outMin + (outMax - outMin) * ratio
end

---@param value number
---@param inMin number
---@param inMax number
---@param outMin number
---@param outMax number
---@return number
function MathUtil.MapRangeClamped(value, inMin, inMax, outMin, outMax)
    if inMin == inMax then return outMin end
    local ratio = (value - inMin) / (inMax - inMin)
    ratio = MathUtil.Clamp(ratio, 0, 1)
    return outMin + (outMax - outMin) * ratio
end

---@param val number
---@return number
function MathUtil.Sign(val)
    if val > 0 then return 1 end
    if val < 0 then return -1 end
    return 0
end

---@param a number
---@param b number
---@param tolerance number
---@return boolean
function MathUtil.IsNearlyEqual(a, b, tolerance)
    tolerance = tolerance or 1e-6
    return math.abs(a - b) <= tolerance
end

---@param degrees number
---@return number
function MathUtil.DegToRad(degrees)
    return degrees * math.pi / 180
end

---@param radians number
---@return number
function MathUtil.RadToDeg(radians)
    return radians * 180 / math.pi
end
]]