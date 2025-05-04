
---
---@brief 植入UECmd的Lua调试转发
---@author zys
---@data Sun May 04 2025 14:20:59 GMT+0800 (中国标准时间)
---

log.error("DebugUtil Loaded")

local M = {}

M.qqq = function()
    log.error("zys: qqq")
end

UECmd = function(Cmd)
    Cmd = Cmd:match('lua (.+)')
    if Cmd then
        local fn = M[Cmd]
        if fn then
            xpcall(fn, function(err)
                log.error("LuaCmdError:", err, '\n', debug.traceback())
            end)
        else
            log.error("DebugUtil找不到这个函数:" .. Cmd)
        end
        return true;
    end;
    return false;
end

return M