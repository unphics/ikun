
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

local Class3 = require("Core/Class/Class3")
local EffectorBaseClass = require("System/Ability/Effect/EffectorBase")
local log = require("Core/Log/log")

---@class BurnClass: EffectorBaseClass
local BurnClass = Class3.Class("BurnClass", EffectorBaseClass)

function BurnClass:OnActiveEffector()
end

function BurnClass:OnApplyEffector()
end

function BurnClass:OnDeactiveEffector()
end

return BurnClass