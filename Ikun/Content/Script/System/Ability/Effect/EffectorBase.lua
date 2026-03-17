
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-效果-效果器
--  File        : EffectorBaseClass.lua
--  Author      : zhengyanshuai
--  Date        : Mon Mar 16 2026 16:31:18 GMT+0800 (中国标准时间)
--  Description : 效果器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')

---@class EffectConfig
---@field EffectKey string
---@field EffectTemplate string 模板
---@field EffectPeroid integer 优先级
---@field EffectDuration number 持续时间
---@field EffectPriority number 周期
---@field EffectTime integer 次数
---@field AttrModFml string
---@field GrantedTags string[]
---@field BlockByTags string[]
---@field CancelToTags string[]

---@class EffectorBaseClass
---@field protected _Manager EffectManager
---@field protected _EffectConfig EffectConfig
local EffectorBaseClass = Class3.Class('EffectorBaseClass')

---@public
function EffectorBaseClass:Ctor(InManager, InConfig)
    self._Manager = InManager
    self._EffectConfig = InConfig
end

function EffectorBaseClass:InitEffector()
end

function EffectorBaseClass:CanActiveEffector()
end

function EffectorBaseClass:ActiveEffector()
end

function EffectorBaseClass:DeactiveEffector()
end

function EffectorBaseClass:ApplyEffector()
end

function EffectorBaseClass:ReapplyEffector()
end

return EffectorBaseClass