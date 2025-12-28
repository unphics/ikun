
local log = require('Core/Log/log')
local vec3 = require('Core/FFI/vec3')


local v1 = vec3(10, 0, 0)
local v2 = vec3(0, 5, 5)
local v3 = v1 + v2
log.dev(v3) -- vec3(10.000, 5.000, 5.000)
local v4 = v3 * 2
log.dev(v4) -- vec3(20.000, 10.000, 10.000)
local dot = v1:dot(v2)
log.dev(dot) -- 0
local cross = v1:cross(v2)
log.dev(cross) -- vec3(0.000, -50.000, 50.000)