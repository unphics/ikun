
---
---@brief   以目标为导向的行为规划
---@author  zys
---@ref     https://www.cnblogs.com/FlyingZiming/p/17274602.html#%E4%B8%96%E7%95%8C%E8%A1%A8%E8%BE%BE
---@data    Sun Sep 28 2025 01:16:57 GMT+0800 (中国标准时间)
---

-- goal
require('System/Goap/Core/GoapUtil')
require('System/Goap/Core/Sensor')
require('System/Goap/Core/Memory')
require('System/Goap/Core/Action')
require('System/Goap/Core/Goal')
require('System/Goap/Core/Planner')
require('System/Goap/Core/Executor')
require('System/Goap/Core/Agent')

-- sensors
require('System/Goap/Sensors/Default')
require('System/Goap/Sensors/Reception')

-- actions
require('System/Goap/Actions/Wait')
require('System/Goap/Actions/WalkOnVillage')
require('System/Goap/Actions/GoHome')
require('System/Goap/Actions/GoStall')
require('System/Goap/Actions/SetupStall')
require('System/Goap/Actions/Sleep')
require('System/Goap/Actions/Hunting')
require('System/Goap/Actions/Counter/GoCounter')
require('System/Goap/Actions/WaitDusk')
require('System/Goap/Actions/WaitEvening')
require('System/Goap/Actions/SaunterDay')
require('System/Goap/Actions/Recept')



---@class goap
---@field util GoapUtil
---@field planner GPlanner
local goap = {}

goap.util = class.GoapUtil
goap.planner = class.GPlanner

return goap