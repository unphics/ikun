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