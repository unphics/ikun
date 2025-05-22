
---
---@brief 植入UECmd的Lua调试转发
---@author zys
---@data Sun May 04 2025 14:20:59 GMT+0800 (中国标准时间)
---

log.error("DebugUtil Loaded")

---@class debug_util
local M = {}

M.debug_bt = 1
M.debugrole = 10102001

M.RotateColor = UE.FLinearColor(0, 1, 0)
M.MoveColor = UE.FLinearColor(1, 1, 0)

M.qqq = function(a, b)
    log.error("zys: qqq", a, b)
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
        local field = M[field_name]
        if field and type(field) == 'function' then
            xpcall(function()
                field(table.unpack(args))
                end, function(err)
                log.error("LuaCmdError:", err, '\n', debug.traceback())
            end)
        elseif field and (type(field) == 'string' or type(field) == "number" or type(field) == "boolean") then
            local value = table.remove(args, 1)
            M[field_name] = tonumber(value) or value
            log.error('LuaCmd: Set debug field [' .. field_name .. '] : ' ..  value)
        else
            log.error("DebugUtil找不到这个函数:" .. Cmd)
        end
        return true;
    end;
    return false;
end

return M