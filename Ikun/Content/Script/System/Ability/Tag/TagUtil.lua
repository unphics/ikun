
--[[
-- -----------------------------------------------------------------------------
--  Brief       : TagUtil
--  File        : TagUtil.lua
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

---@class TagUtil
local TagUtil = {}

---@public
---@return TagContainer
TagUtil.MakeContainer = function()
    return TagContainer()
end

---@public
---@param InTagName string
---@return number
TagUtil.RequestTag = function(InTagName)
    local tag = TagDefine[InTagName]
    if not tag then
        log.error_fmt("TagUtil.RequestTag(): Invalid TagName = [%s]", tostring(InTagName))
    end
    return tag
end

return TagUtil