local math_util = {}

---@param float number
math_util.is_zero = function(float)
    return (float < 0.001) and (float > -0.001)
end

return math_util