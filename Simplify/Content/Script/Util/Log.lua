
---
---@brief UELua开发的Log工具
---@author zys
---@data Sun May 04 2025 14:19:28 GMT+0800 (中国标准时间)
---

---@class log
---@field tb_log table<string, number>
---@field tb_warn table<string, number>
---@field tb_error table<string, number>


local log = {}

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

---@param tag string
---@param vararg string
function log.dev(...)
    UnLua.LogError(...)
end

---@param Chr RoleClass | BP_ChrBase
function log.roleid(Chr)
    local role = log.role(Chr)
    if role then
        return string.format('[%s]', tostring(role.RoleInstId))
    else
        return ''
    end
end

---@param Chr RoleClass | BP_ChrBase
---@return RoleClass
function log.role(Chr)
    if class.instanceof(Chr, class.RoleClass) then
        return Chr
    end
    if Chr.GetRole then
        return Chr:GetRole()
    end
    return nil
end

log.key = {
    luainit = '[Lua初始化]',
    ueinit = '[UE初始化]',
    repos = '[射手站位调整]',
}

log.error(log.key.luainit..' --------------------------------------------------------------------------')

return log