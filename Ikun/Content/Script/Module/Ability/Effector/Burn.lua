
--[[
-- -----------------------------------------------------------------------------
--  Brief       : FireClass
--  File        : Fire.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:29:35 GMT+0800 (中国标准时间)
--  Description : 增益-灼伤
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/class3")
local EffectorBase = require("System/Ability/Effect/EffectorBase")

---@class BurnClass: EffectorBaseClass
local BurnClass = Class3.Class("BurnClass", EffectorBase)

return BurnClass