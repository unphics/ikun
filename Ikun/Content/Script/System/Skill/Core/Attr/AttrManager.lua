

--[[
-- -----------------------------------------------------------------------------
--  Brief       : 技能系统-属性管理器
--  File        : AttrManager.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 16 2026 23:09:10 GMT+0800 (中国标准时间)
--  Description : 管理属性配置, 
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]


local Class3 = require('Core/Class/Class3')

---@class AttrManager
---@field _System SkillSystem
local AttrManager = Class3.Class('AttrManager')

---@private
---@param InSystem SkillSystem
function AttrManager:Ctor(InSystem)
    self._System = InSystem
end

---@public
function AttrManager:InitAttrManager()
end

return AttrManager