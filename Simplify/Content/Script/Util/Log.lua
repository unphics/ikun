
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

function log.log(...)
    print( ...)
end

function log.warn(...)
    UnLua.LogWarn(...)
end

function log.error(...)
    UnLua.LogError(...)
end

function log.dev(...)
    UnLua.LogError(...)
end

---@param inRole RoleClass
---@return boolean
function log.is_live_role(inRole)
    if inRole and not inRole:IsRoleDead() then
        return true
    end
    return false
end

---@param Chr RoleClass | BP_ChrBase
function log.roleid(Chr)
    local role = log.role(Chr)
    if role then
        return string.format('[%s]', tostring(role:GetRoleInstId()))
    else
        return 'undefined'
    end
end

---@param Chr RoleClass | BP_ChrBase
---@return RoleClass?
function log.role(Chr)
    if class.instanceof(Chr, class.RoleClass) then
        return Chr
    end
    if Chr and Chr.GetRole then
        return Chr:GetRole()
    end
    return nil
end

---@param Chr RoleClass | BP_ChrBase
---@return BP_ChrBase?
function log.chr(Chr)
    if class.instanceof(Chr, class.RoleClass) then
        return obj_util.is_valid(Chr.Avatar) and Chr.Avatar or nil
    end
    if Chr.GetRole then
        return obj_util.is_valid(Chr) and Chr or nil
    end
    return nil
end

log.key = {
    luainit     = '[Lua初始化]',
    ueinit      = '[UE初始化]',
    roleinit    = '[角色初始化]',
    repos       = '[射手站位调整]',
    lich02boom  = '[Lich二技能]',
    beha        = '[行为选择]',
    support     = '[支援]',
}

log.error(log.key.luainit..' --------------------------------------------------------------------------')

return log