
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

local TableUtils = require("Core/Utils/TableUtils")
local TagManager = require('System/Ability/Tag/TagManager').Get()

local Tags = {
    "skill.type.active",
    "Ability.Slot.Melee",
    "Effector.State.Burn"
}

---@class TagDefine
---@field tbNameToTag table<string, integer>
---@field tbTagToName table<integer, string>
local TagDefine = {}

TagDefine.tbNameToTag = {}
TagDefine.tbTagToName = TableUtils.MakeArray(TableUtils.DictLength(Tags), -1)

for _, tag in ipairs(Tags) do
    local int = TagManager:Register(tag)
    TagDefine.tbNameToTag[tag] = int
    TagDefine.tbTagToName[int] = tag
end

return TagDefine