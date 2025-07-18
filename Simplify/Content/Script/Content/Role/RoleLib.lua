
---
---@brief   角色相关的帮助函数
---@author  zys
---@data    Sun Jul 06 2025 19:22:01 GMT+0800 (中国标准时间)
---

---@class rolelib
local rolelib = {}

---@public
---@param inRole RoleClass
---@return boolean
rolelib.is_live_role = function(inRole)
    if inRole and not inRole:IsRoleDead() then
        return true
    end
    return false
end

---@param Chr RoleClass | BP_ChrBase
rolelib.roleid = function(Chr)
    local role = rolelib.role(Chr)
    if role then
        return string.format('[%s]', tostring(role:GetRoleInstId()))
    else
        return 'undefined'
    end
end

---@param Chr RoleClass | BP_ChrBase
---@return RoleClass?
rolelib.role = function(Chr)
    if class.instanceof(Chr, class.RoleClass) then
        return Chr ---@as RoleClass
    end
    if Chr and Chr.GetRole then
        return Chr:GetRole()
    end
    return nil
end

---@param Chr RoleClass | BP_ChrBase
---@return BP_ChrBase?
rolelib.chr = function(Chr)
    if class.instanceof(Chr, class.RoleClass) then
        return obj_util.is_valid(Chr.Avatar) and Chr.Avatar or nil
    end
    if Chr.GetRole then
        return obj_util.is_valid(Chr) and Chr or nil
    end
    return nil
end

return rolelib