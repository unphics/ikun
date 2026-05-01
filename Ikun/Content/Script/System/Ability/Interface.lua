
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 战斗系统-接口
--  File        : Interface.lua
--  Author      : zhengyanshuai
--  Date        : Fri May 01 2026 21:18:29 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')

---@class IEffectorContainer
local IEffectorContainer = Class3.Interface("IEffectorContainer")

function IEffectorContainer:AddEffector(InEffector)
end

function IEffectorContainer:RemoveEffector(InEffector)
end

function IEffectorContainer:FindEffectorById(InEffector)
end

---@class IEffectorBase
local IEffectorBase = Class3.Interface('IEffectorBase')

function IEffectorBase:Ctor(InEffectorConfig)
end

---@class IBuff
local IBuff = Class3.Interface("IBuff")

---@class ICombatPart
local ICombatPart = Class3.Interface("ICombatPart")

function ICombatPart:Ctor(InOwnerRole)
end

function ICombatPart:InitCombatPart()
end

function ICombatPart:UninitCombatPart()
end

function ICombatPart:TickCombatPart(InDeltaTime, InTimestampSec)
end

function ICombatPart:ApplyBuff()
end

function ICombatPart:FindBuffsById()
end

function ICombatPart:FindBuffsByTag()
end

function ICombatPart:GetBuffContainer()
end

function ICombatPart:GetAttrSet()
end

function ICombatPart:OnAttributeChanged()
end