
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 植入UECmd的Lua调试转发
--  File        : DebugUtils.lua
--  Author      : zhengyanshuai
--  Date        : Sun May 04 2025 14:20:59 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local TagUtils = require("System/Ability/Tag/TagUtils")
local log = require("Core/Log/log")

---@class DebugUtils
local DebugUtils = {}

local Unpack = table.unpack or _G.unpack
local GameWorld = nil

-- [[
-- 调试变量
-- ]]

DebugUtils.debug_class = false

DebugUtils.debug_bt = 1
DebugUtils.debugrole = 10102001

DebugUtils.RotateColor = UE.FLinearColor(0, 1, 0)
DebugUtils.MoveColor = UE.FLinearColor(1, 1, 0)

-- [[
-- 调试方法
-- ]]

DebugUtils.qqq = function(a, b)
    log.error("zys: qqq", a, b)
end

DebugUtils.printrole = function(id)
    local role = RoleMgr:FindRole(id)
    if role then
        log.error(role:PrintRole())
    end
end

DebugUtils.gamespeed = function(speed)
    local time = TimeMgr ---@type TimeMgr
    time:SetGameSpeed(speed)
end

---@public
---@param Chr BP_ChrBase | RoleBaseClass | number
---@return boolean
DebugUtils.IsChrDebug = function(Chr)
    if type(Chr) == "number" then
        return Chr == DebugUtils.debugrole
    end
    if Chr.GetRole then
        return Chr:GetRole():GetRoleId() == DebugUtils.debugrole
    end
    if class.instanceof(Chr, class.RoleBaseClass) then
        return Chr:GetRoleId() == DebugUtils.debugrole
    end
    return false
end

DebugUtils.skill = function()
    log.mark("DebugUtils.skill begin")
    local name = "鸽鸽"
    local role = RoleMgr:FindRoleByName(name)
    
    if role then
        local part = role.AbilityPart
        local tagName = 'Ability.Slot.Melee'
        local abilities = part:GetSlotAbility(TagUtils.RequestTag(tagName))
        local aa = abilities[1] ---@type AbilityClass
        
        if aa:CanCast(_) then
            aa:CastSkill(_)
        else
            log.error_fmt("释放技能失败[%s]", tagName)
        end
    else
        log.error_fmt("没找到[%s]", name)
    end
    
    log.mark("DebugUtils.skill end")
end

-- [[
-- UECommander接收
-- ]]

local function parse_args(cmd_str)
    local args = {}
    for arg in cmd_str:gmatch("%S+") do
        local num = tonumber(arg)
        table.insert(args, num or arg)
    end
    return args
end

UECmd = function(Cmd, InWorld)
    Cmd = Cmd:match("lua (.+)")
    if Cmd then
        GameWorld = InWorld
        local args = parse_args(Cmd)
        local field_name = table.remove(args, 1)
        local field = DebugUtils[field_name]
        if field and type(field) == "function" then
            xpcall(function()
                field(Unpack(args))
            end, function(err)
                log.error("LuaCmdError:", err, "\n", debug.traceback())
            end)
        elseif field and (type(field) == "string" or type(field) == "number" or type(field) == "boolean") then
            local value = table.remove(args, 1)
            DebugUtils[field_name] = tonumber(value) or value
            log.error("LuaCmd: Set debug field [" .. field_name .. "] : " ..  value)
        else
            log.error("DebugUtils找不到这个函数:" .. Cmd)
        end
        return true;
    end;
    return false;
end

return DebugUtils