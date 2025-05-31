
---
---@biref 默认的最佳战场位置配比(default fight position assign rate)
---@author zys
---@data Wed May 07 2025 21:55:16 GMT+0800 (中国标准时间)
---

local FightPosDef = require 'Content/Role/FightPosDef'

---@class DftFPAsgnRate
local DftFPAsgnRate = {}

---@desc 后排比前排多一点, 方便集火
DftFPAsgnRate[FightPosDef.Frontline] = 1
DftFPAsgnRate[FightPosDef.Backline] = 2

return DftFPAsgnRate