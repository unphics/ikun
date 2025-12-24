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