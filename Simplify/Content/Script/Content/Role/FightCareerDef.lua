---
---@brief 战斗角色定义
---@author zys
---@data Thu Apr 10 2025 22:56:22 GMT+0800 (中国标准时间)
---

---@enum FightCareerDef
local FightCareerDef = {
    MaleeDPS        = 1, -- 近战输出
    RangedDPS       = 2, -- 远程输出
    Tank            = 3, -- 坦克
    CrowdControl    = 4, -- 控场
    Healer          = 5, -- 治疗
    Support         = 6, -- 辅助
    Ganker          = 7, -- 游走
    Summoner        = 8, -- 召唤师
}

return FightCareerDef