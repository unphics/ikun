
---
---@brief 植入UECmd的Lua调试转发
---@author zys
---@data Sun May 04 2025 14:20:59 GMT+0800 (中国标准时间)
---

log.info("debug_util Loaded")

---@class debug_util
local debug_util = {}

debug_util.debug_class = false

debug_util.debug_bt = 1
debug_util.debugrole = 10102001

debug_util.RotateColor = UE.FLinearColor(0, 1, 0)
debug_util.MoveColor = UE.FLinearColor(1, 1, 0)

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
---@param Chr BP_ChrBase | RoleClass | number
---@return boolean
debug_util.IsChrDebug = function(Chr)
    if type(Chr) == "number" then
        return Chr == debug_util.debugrole
    end
    if Chr.GetRole then
        return Chr:GetRole():GetRoleInstId() == debug_util.debugrole
    end
    if class.instanceof(Chr, class.RoleClass) then
        return Chr:GetRoleInstId() == debug_util.debugrole
    end
    return false
end

local function parse_args(cmd_str)
    local args = {}
    for arg in cmd_str:gmatch("%S+") do
        local num = tonumber(arg)
        table.insert(args, num or arg)
    end
    return args
end

UECmd = function(Cmd)
    Cmd = Cmd:match('lua (.+)')
    if Cmd then
        local args = parse_args(Cmd)
        local field_name = table.remove(args, 1)
        local field = debug_util[field_name]
        if field and type(field) == 'function' then
            xpcall(function()
                field(table.unpack(args))
            end, function(err)
                log.error("LuaCmdError:", err, '\n', debug.traceback())
            end)
        elseif field and (type(field) == 'string' or type(field) == "number" or type(field) == "boolean") then
            local value = table.remove(args, 1)
            debug_util[field_name] = tonumber(value) or value
            log.error('LuaCmd: Set debug field [' .. field_name .. '] : ' ..  value)
        else
            log.error("debug_util找不到这个函数:" .. Cmd)
        end
        return true;
    end;
    return false;
end

return debug_util