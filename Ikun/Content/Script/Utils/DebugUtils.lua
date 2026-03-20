
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

local GameWorld = nil
local Unpack = table.unpack or _G.unpack
log.info("debug_util Loaded")

---@class debug_util
local debug_util = {}

-- [[
-- 调试变量
-- ]]

debug_util.debug_class = false

debug_util.debug_bt = 1
debug_util.debugrole = 10102001

debug_util.RotateColor = UE.FLinearColor(0, 1, 0)
debug_util.MoveColor = UE.FLinearColor(1, 1, 0)

-- [[
-- 调试方法
-- ]]

debug_util.qqq = function(a, b)
    log.error("zys: qqq", a, b)
end

debug_util.printrole = function(id)
    local role = RoleMgr:FindRole(id)
    if role then
        log.error(role:PrintRole())
    end
end

debug_util.gamespeed = function(speed)
    local time = TimeMgr ---@type TimeMgr
    time:SetGameSpeed(speed)
end

---@public
---@param Chr BP_ChrBase | RoleBaseClass | number
---@return boolean
debug_util.IsChrDebug = function(Chr)
    if type(Chr) == "number" then
        return Chr == debug_util.debugrole
    end
    if Chr.GetRole then
        return Chr:GetRole():GetRoleId() == debug_util.debugrole
    end
    if class.instanceof(Chr, class.RoleBaseClass) then
        return Chr:GetRoleId() == debug_util.debugrole
    end
    return false
end

debug_util.skill = function()
    log.warn("debug_util.skill begin")
    local name = "鸽鸽"
    local role = RoleMgr:FindRoleByName(name)
    
    if role then
        local part = role.AbilityPart
        local tagName = 'Ability.Slot.Melee'
        local abilities = part:GetSlotAbility(TagUtils.RequestTag(tagName))
        local aa = abilities[1] ---@type AbilityClass
        
        if aa:CanUse(_) then
            aa:UseSkill(_)
        else
            log.error_fmt("释放技能失败[%s]", tagName)
        end
    else
        log.error_fmt("没找到[%s]", name)
    end
    
    log.warn("debug_util.skill end")
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
        local field = debug_util[field_name]
        if field and type(field) == "function" then
            xpcall(function()
                field(Unpack(args))
            end, function(err)
                log.error("LuaCmdError:", err, "\n", debug.traceback())
            end)
        elseif field and (type(field) == "string" or type(field) == "number" or type(field) == "boolean") then
            local value = table.remove(args, 1)
            debug_util[field_name] = tonumber(value) or value
            log.error("LuaCmd: Set debug field [" .. field_name .. "] : " ..  value)
        else
            log.error("debug_util找不到这个函数:" .. Cmd)
        end
        return true;
    end;
    return false;
end

return debug_util