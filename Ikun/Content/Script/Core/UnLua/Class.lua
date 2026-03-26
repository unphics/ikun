
--[[
-- -----------------------------------------------------------------------------
--  Brief       : UE绑定对象的OOP实现
--  File        : UnLuaClass.lua
--  Author      : zhengyanshuai
--  Date        : Sun Mar 22 2026 15:09:33 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local rawget = _G.rawget
local rawset = _G.rawset
local rawequal = _G.rawequal
local type = _G.type
local getmetatable = _G.getmetatable
local require = _G.require

local GetUProperty = _G.GetUProperty
local SetUProperty = _G.SetUProperty

local NotExist = {}

local function Index(t, k)
    local mt = getmetatable(t)
    local super = mt
    while super do
        local v = rawget(super, k)
        if v ~= nil and not rawequal(v, NotExist) then
            rawset(t, k, v)
            return v
        end
        super = rawget(super, "Super")
    end

    local p = mt[k]
    if p ~= nil then
        if type(p) == "userdata" then
            return GetUProperty(t, p)
        elseif type(p) == "function" then
            rawset(t, k, p)
        elseif rawequal(p, NotExist) then
            return nil
        end
    else
        rawset(mt, k, NotExist)
    end

    return p
end

local function NewIndex(t, k, v)
    local mt = getmetatable(t)
    local p = mt[k]
    if type(p) == "userdata" then
        return SetUProperty(t, p, v)
    end
    rawset(t, k, v)
end

local function Class(super_name)
    local super_class = nil
    if super_name ~= nil then
        super_class = require(super_name)
    end

    local new_class = {}
    new_class.__index = Index
    new_class.__newindex = NewIndex
    new_class.Super = super_class

  return new_class
end

return Class