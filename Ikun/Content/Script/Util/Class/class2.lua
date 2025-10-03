
---
---@brief 第三个LuaOOP实现
---@author zys
---



---@class _Class
---@field super table
---@field extends fun(_Class, base:string):table

---@class class
---@field NavMoveData NavMoveData
local classes = {}

local inherit_reserved_keyword = {
    __class_name = 1,
    __base_class_name = 2,
}

local function inherit_var(derive, base)
    derive.super = {}
    for k, v in pairs(base) do
        if inherit_reserved_keyword[k] then
            derive.super[k] = v
            goto continue
        end
        if type(v) == 'function' then goto continue end
        if derive[k] then goto continue end
        if k == 'super' then goto continue end
        derive[k] = v
        ::continue::
    end
end
local function inherit_fn(derive, base)
    for k, v in pairs(base) do
        -- log.error('zys var type', tostring(k), type(k), tostring(v), type(v))
        if type(v) == 'function' then
            derive.super[k] = v
        end
    end
    local mt = getmetatable(base)
    if mt then
        setmetatable(derive.super, {__index = base})
    end
end

local function create_class(class_name, structure, super_class)
    if (classes[class_name]) then -- 重复注册
    end
    local new_class = structure -- deepcopy(structure)
    new_class.__class_name = class_name
    if super_class then
        inherit_var(new_class, super_class)
        inherit_fn(new_class, super_class)
        new_class.super.super = super_class.super
        new_class.__base_class_name = super_class.__class_name
        setmetatable(new_class, {__index = new_class.super})
    end
    classes[class_name] = new_class
    return new_class
end

local internal_name = {
    class = 1,
    new = 2,
    instanceof = 3,
    extends = 4
}

-- 以上, 单元测试1

---@return _Class
function classes.class(class_name)
    if internal_name[class_name] then
        return log.error('class error: invalid class_name --- internal_name : ' .. class_name) ---@as _Class
    end
    local new_class = {}
    local modifiers = {
        extends = function(self, super_class_name)
            return function(subclass)
                local super_class = classes[super_class_name]
                if not super_class then
                    log.error('class error : invalid super_class_name : ' .. super_class_name .. ', in class_name : ' .. class_name)
                end
                local class_created = create_class(class_name, subclass, super_class)
                return class_created
            end
        end
    }
    setmetatable(new_class, {
        __index = function (self, key)
            if modifiers[key] then
                return modifiers[key]
            end
            if classes[class_name] then
                return classes[class_name][key]
            end
            log.error("class error : class not found : " .. class_name)
        end,
        __call = function(self, ...)
            local new_inst = create_class(class_name, ...)
            return new_inst
        end
    })
    return new_class ---@as _Class
end

-- 以上, 单元测试2
function classes.new(class_name)
    return function(...)
        local classe = classes[class_name]
        if not classe then
            log.fatal("fatal error = class2 : class not found : " .. tostring(class_name))
            return
        end
        -- local new_obj = deepcopy(classe)
        local new_obj = {}
        for k, v in pairs(classe) do
            if inherit_reserved_keyword[k] then
                new_obj[k] = v
                goto coontinue
            end
            new_obj[k] = v
            ::coontinue::
        end
        setmetatable(new_obj, {__index = classe})
        if new_obj.ctor then
            new_obj:ctor(...)
        end
        return new_obj
    end
end
local function deriveof(derive, base)
    if derive.__class_name == base.__class_name then
        return true
    end
    local CurClass = derive
    local limit = 10
    while true do
        if limit < 0 then
            break
        end
        limit = limit - 1
        CurClass = CurClass.super
        if not CurClass then
            break
        end
        if CurClass.__class_name == base.__class_name then
            return true
        end
    end
    return false
    
end

function classes.instanceof(Object, Class)
    if not Object or not Object.__class_name or not Class or not Class.__class_name then
        return false
    end
    local ObjectClass = classes[Object.__class_name]
    if not ObjectClass then
        return false
    end
    local ClassClass = Class
    if type(Class) == 'string' then
        ClassClass = classes[Class]
    end
    return deriveof(ObjectClass, ClassClass)
end

-- 以上, 单元测试3

return classes