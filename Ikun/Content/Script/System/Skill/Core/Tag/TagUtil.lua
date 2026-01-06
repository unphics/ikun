
--[[
-- -----------------------------------------------------------------------------
--  Brief       : TagUtil
--  File        : TagUtil.lua
--  Author      : zhengyanshuai
--  Date        : Sat Jan 03 2026 21:50:43 GMT+0800 (中国标准时间)
--  Description : 表工具方法
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]


local TagContainer = require('System/Skill/Core/Tag/TagContainer')
local TagDefine = require('System/Skill/Core/Tag/TagDefine')

---@class TagUtil
local TagUtil = {}

---@public
---@return TagContainer
TagUtil.MakeContainer = function()
    return TagContainer()
end

---@public
TagUtil.RequestTag = function(InTagName)
    return TagDefine[InTagName]
end

return TagUtil