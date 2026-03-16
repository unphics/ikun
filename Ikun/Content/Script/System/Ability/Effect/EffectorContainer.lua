

--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-增益-效果器容器
--  File        : EffectorContainer.lua
--  Author      : zhengyanshuai
--  Date        : Mon Mar 16 2026 22:33:19 GMT+0800 (中国标准时间)
--  Description : 效果器容器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")

---@class EffectorContainer
---@field _EffectManager EffectManager
---@field _OwnerPart AbilityPartClass
local EffectorContainer = Class3.Class("EffectorContainer")

---@public
function EffectorContainer:ctor(InEffectManager, InPart)
    self._EffectManager = InEffectManager
    self._OwnerPart = InPart
end



return EffectorContainer