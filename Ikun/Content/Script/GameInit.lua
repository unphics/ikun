
---
---@brief   服务端初始化顺序管理
---@author  zys
---@data    Tue Sep 23 2025 11:13:55 GMT+0800 (中国标准时间)
---

---@class gameinit
local gameinit = {}

gameinit.initring = {}

---@step 一环初始化, 全局无状态Lib, 无状态Uitl等无状态模块初始化
gameinit.initring[1] = {}
---@step 二环初始化, 全局模块管理, 重要游戏内容模块初始化
gameinit.initring[2] = {}
---@step
gameinit.initring[3] = {}

return gameinit