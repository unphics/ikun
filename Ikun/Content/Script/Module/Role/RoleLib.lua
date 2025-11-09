
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
function rolelib.is_live_role(inRole)
    if inRole and not inRole:IsRoleDead() then
        return true
    end
    return false
end

---@public
---@param Chr RoleClass | BP_ChrBase | GAgent | GMemory
function rolelib.roleid(Chr)
    local role = rolelib.role(Chr)
    if role then
        return string.format('[%s]', tostring(role:GetRoleId()))
    else
        return 'undefined'
    end
end

---@public
---@param Obj RoleClass | BP_ChrBase | GAgent | AgentPartInterface
---@return RoleClass?
function rolelib.role(Obj)
    if class.instanceof(Obj, class.RoleClass) and obj_util.is_valid(Obj.Avatar) then
        return Obj ---@as RoleClass
    end
    if Obj and Obj.GetRole and obj_util.is_valid(Obj) then
        return Obj:GetRole()
    end
    if class.instanceof(Obj, class.GAgent) then
        return Obj._OwnerRole
    end
    if Obj and Obj._OwnerAgent then
        return Obj._OwnerAgent._OwnerRole
    end
    return nil
end

---@public
---@param Chr RoleClass | BP_ChrBase
---@return BP_ChrBase?
function rolelib.chr(Chr)
    local role = rolelib.role(Chr)
    if role and obj_util.is_valid(role.Avatar) then
        return role.Avatar
    end
    return nil
end

---@public
function rolelib.is_valid_enemy(target, owner)
    local targetRole = rolelib.role(target)
    if not targetRole then
        return false
    end
    local ownerRole = rolelib.role(owner)
    if not ownerRole then
        return false
    end
    if not ownerRole:IsEnemy(targetRole) then
        return false
    end
    return true
end

return rolelib