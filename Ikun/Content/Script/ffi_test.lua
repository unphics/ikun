

ffi.cdef [[
    typedef struct  {
        float x;
        float y;
    } CT_Vector2;
]]

local MT_Vector2 = {}
MT_Vector2.__index = MT_Vector2

local Vector2 = ffi.metatype("CT_Vector2", MT_Vector2)

function MT_Vector2:Add(rhs)
    self.x = self.x + rhs.x
    self.y = self.y + rhs.y
end

function MT_Vector2:__tostring()
    return string.format("Vec2(%f, %f)", self.x, self.y)
end

local v1 = Vector2(11, 3)
local v2 = Vector2(3, 5)

v1:Add(v2)

print('ffi', v1)