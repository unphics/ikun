# LuaJITFFI 使用说明
## 使用简介
```
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
```
## 交互规则
### 内部交互（Lua 内部）
| 源数据 | 目标 | 行为准则 | 建议 |
|--------|------|----------|------|
| FFI int/float | Lua 变量 | 值拷贝 | 可以安全使用 |
| FFI Struct | Lua 变量 | 引用（指针） | 注意，修改变量会影响原始内存 |
| Lua String | FFI char[] | 数据拷贝 | 用于存储名字，安全 |
| Lua String | FFI char* | 存储地址（危险） | 不推荐使用，除非理解 GC 机制 |
### 外部交互（Lua 与 UE 之间）
| 源数据 | 目标 | 行为准则 | 建议 |
|------|------|----------|------|
| FFI int/float | UE 函数参数 | 自动转换 | 直接传递即可 |
| FFI Struct | UE FVector | 不兼容 | 手动转换为 UE.FVector(x,y,z) |
| UE Actor | FFI void* | 使用 ffi.cast 转换 | 只存储指针，不会保持对象存活（Actor 销毁后指针会悬空） |
### 使用注意事项
1. **内存管理**：FFI 结构体使用引用传递，修改会影响原始内存，需谨慎操作
2. **字符串安全**：使用 char[] 而非 char* 来存储字符串，避免 GC 导致的内存问题
3. **类型转换**：FFI 结构体与 UE 类型不兼容，需要手动转换
4. **生命周期**：存储 UE 对象指针时，需注意对象可能被销毁导致指针悬空
5. **性能考量**：频繁的类型转换会影响性能，尽量减少不必要的转换操作
## 位运算
```
local ffi = require("ffi")

ffi.cdef[[
    typedef struct {
        uint8_t  has_target;   -- 1 字节
        uint8_t  _pad[3];      -- 手动补齐 3 字节，使下一个 float 对齐到 4 字节边界
        float    health;       -- 4 字节 (偏移量 4)
        uint16_t ammo;         -- 2 字节
        uint8_t  _pad2[2];     -- 手动补齐 2 字节，使整个结构体大小为 4 的倍数
    } EntityState;
]]

print(ffi.offsetof("EntityState", "health")) -- 输出 4，符合预期
print(ffi.sizeof("EntityState"))             -- 输出 12



--[[
在设计 GOAP 的 cdata 结构体时，遵循**“从大到小”**的原则排列成员。这样可以利用自然对齐规律，最大限度减少填充空间，提高内存紧凑度。
顺序：double (8) -> int64 (8) -> float (4) -> int32 (4) -> int16 (2) -> int8 (1)。
--]]
ffi.cdef[[
    typedef struct {
        double   last_plan_time; -- 8 字节 (偏移 0)
        float    health;         -- 4 字节 (偏移 8)
        float    move_speed;     -- 4 字节 (偏移 12)
        uint16_t ammo;           -- 2 字节 (偏移 16)
        uint8_t  has_target;     -- 1 字节 (偏移 18)
        uint8_t  is_dead;        -- 1 字节 (偏移 19)
        -- 此时总长度 20，编译器可能还会自动补 4 字节到 24 字节，以对齐到 double 的 8 字节边界
    } OptimizedState;
]]
```
## LuaJIT避坑指南
1. 不要在循环中调用跨语言接口, 速度极慢或导致JIT失败回退; 写一个宿主语言接口内部处理一次开销
2. NYI: pairs(), next(), string部分如match和gmatch, table.insert和table.remove, debug全部
3. 不要在循环里ffi.new; 尽量在循环外写tmp
4. Lua全局变量查找(_G)是很慢的; 尽量在文件头缓存如local sin = math.sin;
## ECS友好
```

local ffi = require("ffi")

local EntityManager = {}

-- 预分配 10000 个单位的内存
-- 这是一块巨大的连续内存，Cache 极其友好
local MAX_COUNT = 10000
local entities = ffi.new("GameEntity[?]", MAX_COUNT)
local count = 0

-- 创建新单位
function EntityManager.Spawn(x, y, team)
    if count >= MAX_COUNT then return nil end
    
    local e = entities[count] -- 获取引用（其实就是指针）
    count = count + 1
    
    -- 初始化数据
    e.id = count
    e.pos.x = x
    e.pos.y = y
    e.stats.hp = 100
    e.state.team_id = team
    
    return e -- 返回这个 cdata 指针
end

-- 逻辑更新：这是 LuaJIT 最爽的地方
function EntityManager.Update(dt)
    -- 这是一个极度紧凑的循环
    -- JIT 会把它编译成类似 SIMD 的高效指令
    for i = 0, count - 1 do
        local e = entities[i]
        
        -- 1. 处理冷却
        if e.cd.q_cd > 0 then e.cd.q_cd = e.cd.q_cd - dt end

        -- 2. 简单的移动逻辑 (纯 Lua 计算)
        if e.state.is_moving then
            e.pos.x = e.pos.x + 1.0 * dt
        end

        -- 3. 死亡判定
        if not e.state.is_dead and e.stats.hp <= 0 then
            e.state.is_dead = true
            -- 可以在这里调用 UE 接口播放死亡特效
            -- UE.MyFuncLib.PlayEffect(e.pos.x, e.pos.y)
        end
    end
end

return EntityManager
```