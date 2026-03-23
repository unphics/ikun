
--[[
-- -----------------------------------------------------------------------------
--  Brief       : IkunAttrSetClass
--  File        : IkunAttrSet.lua
--  Author      : zhengyanshuai
--  Date        : Sun Mar 22 2026 23:02:55 GMT+0800 (中国标准时间)
--  Description : Ikun属性集
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local AttrDef = require("System/Ability/Attr/AttrDef")
local log = require("Core/Log/log")
local table_util = require("Core/Utils/table_util")
local AttrSetClass = require("System/Ability/Attr/AttrSet")

---@class IkunAttrSetClass: AttrSetClass
local IkunAttrSetClass = Class3.Class("IkunAttrSetClass", AttrSetClass)

function IkunAttrSetClass:OnAttrIncomingDamageChanged(NewValue, OldValue)
end

return IkunAttrSetClass