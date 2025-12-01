local ffi = require("ffi")

ffi.cdef[[
    typedef struct { float x, y; } Vector2;
]]

-- 定义一组方法
local Vector2_MT = {}
Vector2_MT.__index = Vector2_MT

-- 相当于 C++ 的 Vector2::Add
function Vector2_MT:Add(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
end

-- 相当于 C++ 的 ToString
function Vector2_MT:__tostring()
    return string.format("Vec2(%f, %f)", self.x, self.y)
end

-- 【关键】绑定元表到 C 类型
local Vector2 = ffi.metatype("Vector2", Vector2_MT)

------------------------------------------
-- 使用
local v1 = Vector2(10, 20) -- 像构造函数一样创建
local v2 = Vector2(5, 5)

v1:Add(v2) -- 调用方法，性能极高（JIT 会内联这个调用）

print(v1) -- 输出: Vec2(15.000000, 25.000000)