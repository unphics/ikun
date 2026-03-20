
--[[
-- -----------------------------------------------------------------------------
--  Brief       : TagUtils
--  File        : TagUtils.lua
--  Author      : zhengyanshuai
--  Date        : Sat Jan 03 2026 21:50:43 GMT+0800 (中国标准时间)
--  Description : Tag工具方法
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]


local TagContainer = require('System/Ability/Tag/TagContainer')
local TagDefine = require('System/Ability/Tag/TagDefine')
local log = require("Core/Log/log")

---@class TagUtils
local TagUtils = {}

---@public
---@return TagContainer
TagUtils.MakeContainer = function()
    return TagContainer()
end

---@public
---@return integer
TagUtils.RequestTag = function(InTagName)
    local tag = TagDefine.tbNameToTag[InTagName]
    if not tag then
        log.error_fmt("TagUtils.RequestTag(): Invalid TagName = [%s]", tostring(InTagName))
    end
    return tag
end

---@public
---@return string?
TagUtils.LookupTagName = function(InTag)
    return TagDefine.tbTagToName[InTag]
end

return TagUtils