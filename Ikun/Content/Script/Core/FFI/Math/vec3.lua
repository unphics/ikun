
--[[
-- -----------------------------------------------------------------------------
--  Brief       : Core-FFI-Math-Vector3
--  File        : vec3.lua
--  Author      : zhengyanshuai
--  Date        : Sat Dec 06 2025 09:09:25 GMT+0800 (中国标准时间)
--  Description : cdata的vector3实现, 用于优化Lua侧的性能
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local fficlass = require("Core/FFI/fficlass")

---@class vec3
---@field public x number
---@field public y number
---@field public z number
local vec3 = fficlass.define('vec3', [[
    typedef struct {
        double x, y, z;
    } vec3;
]])

---@public
---@param rhs vec3 named"rhs" is "right-hand side" 右操作数
---@return vec3
function vec3:__add(rhs)
    return vec3(self.x + rhs.x, self.y + rhs.y, self.z + rhs.z)
end

---@public
---@param out vec3
---@param a vec3
---@param b vec3
function vec3.add_to(out, a, b)
    out.x = a.x + b.x
    out.y = a.y + b.y
    out.z = a.z + b.z
end

---@public
---@param rhs vec3
---@return vec3
function vec3:__sub(rhs)
    return vec3(self.x - rhs.x, self.y - rhs.y, self.z - rhs.z)
end

---@public
---@param rhs vec3|number
---@return vec3
function vec3:__mul(rhs)
    if type(rhs) == "number" then
        return self:mul_scalar(rhs)
    else
        return self:mul_vec(rhs)
    end
end

---@public
---@param num number
---@return vec3
function vec3:mul_scalar(num)
    return vec3(self.x * num, self.y * num, self.z * num)
end

---@public
---@param vec vec3
---@return vec3
function vec3:mul_vec(vec)
    return vec3(self.x * vec.x, self.y * vec.y, self.z * vec.z)
end

---@public
---@param scalar number
---@return vec3
function vec3:__div(scalar)
    local inv = 1.0 / scalar
    return vec3(self.x * inv, self.y * inv, self.z * inv)
end

---@public
---@return vec3
function vec3:__unm()
    return vec3(-self.x, -self.y, -self.z)
end

---@public
---@param rhs vec3
---@return boolean
function vec3:__eq(rhs)
    return self.x == rhs.x and self.y == rhs.y and self.z == rhs.z
end

---@public
---@return string
function vec3:__tostring()
    return string.format('vec3(%.3f, %.3f, %.3f)', self.x, self.y, self.z)
end

---@public
---@param rhs vec3
---@return number
function vec3:dot(rhs)
    return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z
end

---@public
---@param rhs vec3
---@return vec3
function vec3:cross(rhs)
    return vec3(
        self.y * rhs.z - self.z * rhs.y,
        self.z * rhs.x - self.x * rhs.z,
        self.x * rhs.y - self.y * rhs.x
    )
end

---@public
---@return number
function vec3:sizesquared()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

---@public
---@return number
function vec3:size()
    return math.sqrt(self:sizesquared())
end

---@public
---@return vec3
function vec3:getnormal()
    local sq = self:sizesquared()
    if sq < 1e-8 then
        return vec3(0, 0, 0)
    end
    local scale = 1 / math.sqrt(sq)
    return vec3(self.x * scale, self.y * scale, self.z * scale)
end

---@public
---@return vec3
function vec3:normalize()
    local sq = self:sizesquared()
    if sq < 1e-8 then 
        self.x, self.y, self.z = 0, 0, 0
    else
        local scale = 1.0 / math.sqrt(sq)
        self.x = self.x * scale
        self.y = self.y * scale
        self.z = self.z * scale
    end
end

---@public
---@return FVector
function vec3:toUE()
    return UE.FVector(self.x, self.y, self.z)
end

---@public
---@param fvec FVector
function vec3:fromUE(fvec)
    self.x = fvec.X
    self.y = fvec.Y
    self.z = fvec.Z
end

vec3 = vec3:RegisterClass()

local v1 = vec3(10, 0, 0)
local v2 = vec3(0, 5, 5)
local v3 = v1 + v2 -- vec3(10.000, 5.000, 5.000)

assert(v3.x == 10 and v3.y == 5 and v3.z == 5, "加法测试失败")
local v4 = v3 * 2 -- vec3(20.000, 10.000, 10.000)
assert(v4.x == 20 and v4.y == 10 and v4.z == 10, "数乘测试失败")
local dot = v1:dot(v2) -- 0
assert(dot == 0, "点乘测试失败")
local cross = v1:cross(v2) -- vec3(0.000, -50.000, 50.000)
assert(cross.x == 0 and cross.y == -50 and cross.z == 50, "叉乘测试失败")

return vec3