
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
---@param rhs vec3
---@return vec3
function vec3:__add(rhs)
    return vec3(self.x + rhs.x, self.y + rhs.y, self.z + rhs.z)
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
        return vec3(self.x * rhs, self.y * rhs, self.z * rhs)
    else
        return vec3(self.x * rhs.x, self.y * rhs.y, self.z * rhs.z)
    end
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

vec3 = vec3:Register()

return vec3
