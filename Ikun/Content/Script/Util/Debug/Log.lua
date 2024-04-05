
---@class log
---@field tb_log table<string, number>
---@field tb_warn table<string, number>
---@field tb_error table<string, number>


log = {}

---@param tag string
---@param vararg string
function log.log(tag, ...)
    print( ...)
end

---@param tag string
---@param vararg string
function log.warn(tag, ...)
    UnLua.LogWarn(...)
end

---@param tag string
---@param vararg string
function log.error(tag, ...)
    UnLua.LogError(...)
end

return log