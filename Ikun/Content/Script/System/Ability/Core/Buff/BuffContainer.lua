
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-增益-增益容器
--  File        : BuffContainer.lua
--  Author      : zhengyanshuai
--  Date        : Wed Feb 11 2026 21:32:02 GMT+0800 (中国标准时间)
--  Description : 增益容器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')

---@class BuffContainerClass
---@field _OwnerPart AbilityPartClass
local BuffContainerClass = Class3.Class('BuffClass')

---@param InPart AbilityPartClass
function BuffContainerClass:Ctor(InPart)
    self._OwnerPart = InPart
end



return BuffContainerClass