
---
---@brief   luaffi oop
---@author  zys
---@data    Sat Dec 06 2025 09:09:25 GMT+0800 (中国标准时间)
---

local ffi = require('ffi')

---@class fficlass
local fficlass = {}

---@public 定义一个ffi类
---@param c_type_name string C语言中的结构体名字
---@param c_def string|nil C语言的结构体定义, 如果已经定义过, 传nil
function fficlass.define(c_type_name, c_def)
    if c_def then
        pcall(ffi.cdef, c_def)
    end

    local mt = {}
    mt.__index = mt

    function mt:Register()
        self.Register = nil
        return ffi.metatype(c_type_name, self)
    end

    return mt
end

return fficlass