
--[[
-- -----------------------------------------------------------------------------
--  Brief       : TagDefine
--  File        : TagDefine.lua
--  Author      : zhengyanshuai
--  Date        : Sat Jan 03 2026 20:28:06 GMT+0800 (中国标准时间)
--  Description : 能力系统-标签定义
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local TagManager = require('System/Ability/Tag/TagManager').Get()

local Tags = {
    "skill.type.active",
    "Ability.Slot.Melee"
}

local TagDefine = {}

for _, tag in ipairs(Tags) do
    TagDefine[tag] = TagManager:Register(tag)
end

return TagDefine