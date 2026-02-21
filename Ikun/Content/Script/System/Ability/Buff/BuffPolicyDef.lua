
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-增益-增益策略定义
--  File        : BuffPolicyDef.lua
--  Author      : zhengyanshuai
--  Date        : Tue Feb 10 2026 14:31:04 GMT+0800 (中国标准时间)
--  Description : 定义增益的策略, 如立即生效, 有持续时间, 无限期生效等
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

---@enum BuffPolicyDef
local BuffPolicyDef = {
    Instant = "Instant",
    HasDuration = "HasDuration",
    Infinite = "Infinite",
}

return BuffPolicyDef