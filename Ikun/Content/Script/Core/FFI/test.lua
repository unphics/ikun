
local vec3 = require('Core/FFI/vec3')


local v1 = vec3(10, 0, 0)
local v2 = vec3(0, 5, 5)
local v3 = v1 + v2
log.dev(v3)
local v4 = v3 * 2
log.dev(v4)
local dot = v1:dot(v2)
log.dev(dot)
local cross = v1:cross(v2)
log.dev(cross)
