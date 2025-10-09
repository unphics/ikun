
---
---@brief   以目标为导向的行为规划
---@author  zys
---@ref     https://www.cnblogs.com/FlyingZiming/p/17274602.html#%E4%B8%96%E7%95%8C%E8%A1%A8%E8%BE%BE
---@data    Sun Sep 28 2025 01:16:57 GMT+0800 (中国标准时间)
---

require('Ikun/Module/AI/Goap/Core/GoapUtil')
require('Ikun/Module/AI/Goap/Core/Sensor')
require('Ikun/Module/AI/Goap/Core/Memory')
require('Ikun/Module/AI/Goap/Core/Action')
require('Ikun/Module/AI/Goap/Core/Goal')
require('Ikun/Module/AI/Goap/Core/Planner')
require('Ikun/Module/AI/Goap/Core/Executor')
require('Ikun/Module/AI/Goap/Core/Agent')

-- sensors
require('Ikun/Module/AI/Goap/Sensors/Default')

-- actions
require('Ikun/Module/AI/Goap/Actions/Wait')
require('Ikun/Module/AI/Goap/Actions/WalkOnVillage')
require('Ikun/Module/AI/Goap/Actions/GoHome')
require('Ikun/Module/AI/Goap/Actions/GoStall')
require('Ikun/Module/AI/Goap/Actions/SetupStall')
require('Ikun/Module/AI/Goap/Actions/Sleep')
require('Ikun/Module/AI/Goap/Actions/Hunting')

---@class goap
---@field util GoapUtil
---@field planner GPlanner
local goap = {}

goap.util = class.GoapUtil
goap.planner = class.GPlanner



return goap