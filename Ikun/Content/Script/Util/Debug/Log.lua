
---@class log
---@field tb_log table<string, number>
---@field tb_warn table<string, number>
---@field tb_error table<string, number>


log = {}

---@param tag string
---@param vararg string
function log.log(...)
    print( ...)
end

---@param tag string
---@param vararg string
function log.warn(...)
    UnLua.LogWarn(...)
end

---@param tag string
---@param vararg string
function log.error(...)
    UnLua.LogError(...)
end

return log