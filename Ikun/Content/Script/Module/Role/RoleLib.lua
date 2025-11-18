
---
---@brief   角色相关的帮助函数
---@author  zys
---@data    Sun Jul 06 2025 19:22:01 GMT+0800 (中国标准时间)
---@todo    从RoleLib改成RoleUtil
---

---@class rolelib
local rolelib = {}

---@public 判断角色还活着
---@param inRole RoleBaseClass
---@return boolean
function rolelib.is_live_role(inRole)
    if inRole and not inRole:IsRoleDead() then
        return true
    end
    return false
end

---@public 易用接口获取角色Id
---@param Chr RoleBaseClass | BP_ChrBase | GAgent | GMemory
function rolelib.roleid(Chr)
    local role = rolelib.role(Chr)
    if role then
        return string.format('[%s]', tostring(role:GetRoleId()))
    else
        return 'undefined'
    end
end

---@public 易用接口获取角色对象
---@param Obj RoleBaseClass | BP_ChrBase | GAgent | AgentPartInterface
---@return RoleBaseClass?
function rolelib.role(Obj)
    if class.instanceof(Obj, class.RoleBaseClass) and obj_util.is_valid(Obj.Avatar) then
        return Obj ---@as RoleBaseClass
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

---@public 易用接口获取角色的AvatarChr
---@param Chr RoleBaseClass | BP_ChrBase | GAgent | AgentPartInterface
---@return BP_ChrBase?
function rolelib.chr(Chr)
    local role = rolelib.role(Chr)
    if role and obj_util.is_valid(role.Avatar) then
        return role.Avatar
    end
    return nil
end

---@public 判断是一个有效的敌人
---@return boolean
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