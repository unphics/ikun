
--[[
-- -----------------------------------------------------------------------------
--  Brief       : BoomClass
--  File        : Boom.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:29:35 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local EffectorBaseClass = require("System/Ability/Effect/EffectorBase")
local log = require("Core/Log/log")

---@class BoomClass: EffectorBaseClass
local BoomClass = Class3.Class("BoomClass", EffectorBaseClass)

function BoomClass:OnActiveEffector()
end

function BoomClass:OnApplyEffector()
    local ctx = self:MakeInteractContext()
    self:ApplyAttrInteract(ctx)
end

function BoomClass:OnDeactiveEffector()
end

return BoomClass