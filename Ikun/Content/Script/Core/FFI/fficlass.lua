
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
        local ok, err = pcall(ffi.cdef, c_def)
        if not ok then
            local err_msg = tostring(err)
            local str = "\n============================================================================================\n"
            str = str .. "❌ [FFI Error] Failed to define struct: " .. tostring(c_type_name) .. '\n'
            str = str .. "Error Message: " .. err_msg .. "\n"
            str = str .. "Context (C Code):\n" .. c_def .. "\n"
            str = str .. "============================================================================================"
            log.error(str)
        end
    end

    local mt = {}
    mt.__index = mt

    function mt:Register()
        self.Register = nil

        local raw_ctor = ffi.metatype(c_type_name, self)

        local class_proxy = {}

        setmetatable(class_proxy, {
            __call = function(_,...)
                return raw_ctor(...)
            end,
            __index = self
        })

        return class_proxy
    end

    return mt
end

return fficlass