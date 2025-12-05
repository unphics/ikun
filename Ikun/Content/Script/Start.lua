
---
---@brief   双端LuaState最先加载
---@author  zys
---@data    Sat Apr 05 2025 14:07:42 GMT+0800 (中国标准时间)
---

_G.ffi = require ("ffi") ---@type ffilib

print("========================================")
print("[Check] Lua Version Check:")
print("Global _VERSION: " .. tostring(_VERSION))

if jit then
    print("✅ JIT Enabled!")
    print("   - Version: " .. tostring(jit.version))
    print("   - Arch:    " .. tostring(jit.arch))
    print("   - OS:      " .. tostring(jit.os))
    
    -- 检查 JIT 编译器是否真的在工作
    if jit.status() then
        print("   - Status:  Running (Optimizing code)")
    else
        print("   - Status:  OFF (Interpreter mode)")
    end
else
    print("❌ No JIT detected! You are running standard Lua.")
end
print("========================================")

require('SharedPCH')