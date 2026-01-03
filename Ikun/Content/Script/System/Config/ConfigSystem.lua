
---
---@brief   ConfigSystem
---@author  zys
---@data    Sat Jan 03 2026 00:17:13 GMT+0800 (中国标准时间)
---

local Class3 = require('Core/Class/Class3')
local IConfigSystem = require('System/Config/Interface').IConfigSystem
local ConfigParserClass = require('System/Config/ConfigParser')

---@class ConfigSystem: IConfigSystem
local ConfigSystem = Class3.Class('ConfigSystem', IConfigSystem)

local system = nil

---@protected
function ConfigSystem:Ctor()
end

---@public
---@return ConfigSystem
function ConfigSystem.Get()
    if not system then
        system = ConfigSystem:New()
    end
    return system
end

---@public
function ConfigSystem:InitConfigSystem()
end

---@public
---@param InConfigStr string
---@return ConfigParserClass?
function ConfigSystem:CreateCSVParser(InConfigStr)
    if not InConfigStr then
        return
    end
    return ConfigParserClass:New(InConfigStr, self) ---@as ConfigParserClass
end

---@public
---@param InContext ConfigParserClass
function ConfigSystem:ReleaseParser(InContext)
end

return ConfigSystem