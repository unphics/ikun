
---@class log
---@field tb_log table<string, number>
---@field tb_warn table<string, number>
---@field tb_error table<string, number>


log = {}

log.tb_log = {}
log.tb_warn = {}
log.tb_error = {}

---@param tag string
---@param vararg string
function log.log(tag, ...)
    if not log.tb_log[tag] then
        log.tb_log[tag] = 1
    else
        log.tb_log[tag] = log.tb_log[tag] + 1
    end
    print( tag .. '_' .. log.tb_log[tag], ...)
end

---@param tag string
---@param vararg string
function log.warn(tag, ...)
    if not log.tb_warn[tag] then
        log.tb_warn[tag] = 1
    else
        log.tb_warn[tag] = log.tb_warn[tag] + 1
    end
    UnLua.LogWarn(tag .. '_' .. log.tb_warn[tag], ...)
end

---@param tag string
---@param vararg string
function log.error(tag, ...)
    if not log.tb_error[tag] then
        log.tb_error[tag] = 1
    else
        log.tb_error[tag] = log.tb_error[tag] + 1
    end
    UnLua.LogError(tag .. '_' .. log.tb_error[tag], ...)
end

return log