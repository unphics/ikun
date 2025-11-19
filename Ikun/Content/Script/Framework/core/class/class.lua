
---
---@brief   lua oop
---@author  zys
---@data    Mon Jan 13 2025 14:53:06 GMT+0800 (中国标准时间)
---

---@class __class
---@field super table
---@field extends fun(__classs, base: string, ...: string):table

---@class class
local classes = {}

local inherit_reserved_keyword = {
    __class_name = -1,
    __base_class_name = -2,
}

-- 将基类的的非函数成员变量复制到派生类, 同时建立基础关系
local function inherit_vars(derive, bases)
    derive.super = {}
    local inherit_keys = {}
    for _, base in ipairs(bases) do
        for k, v in pairs(base) do
            if inherit_reserved_keyword[k] then -- 处理保留关键字
                derive.super[k] = v -- 保留关键字存入super表
                goto continue
            end
            if type(v) == "function" then -- 跳过成员函数
                goto continue
            end
            if derive[k] then -- 派生类已有该成员则跳过(不覆盖)
                goto continue
            end
            if k == 'super' then -- 跳过super关键字
                goto continue
            end
            if inherit_keys[k] then -- 如果多个基类有同名变量, 使用第一个遇到的
                -- todo zys 警告

                goto continue
            end
            derive[k] = v -- 复制成员变量
            ::continue::
        end
    end
end

-- 将基类的函数方法设置到派生类的super表中, 建立函数继承类
local function inherit_fns(derive, bases)
    for i, base in ipairs(bases) do
        local super_table = {}
        derive.super[i] = super_table
        
        for k, v in pairs(base) do -- 复制基类的所有函数到derive.super表
            if type(v) == 'function' then
                super_table[k] = v-- 将函数存入super表
            end
        end
        
        -- 设置元表以支持链式调用
        local mt = getmetatable(base)
        if mt then
            setmetatable(super_table, {__index = base})
        end
    end
end

local function create_class(class_name, structure, super_classes)
    if classes[class_name] then
        -- todo zys
    end

    local new_class = structure
    new_class.__class_name = class_name
    
    if super_classes and #super_classes > 0 then
        local base_names = {} -- 收集所有基类名称
        for _, super_class in ipairs(super_classes) do
            table.insert(base_names, super_class.__class_name)
        end
        new_class.__base_class_names = base_names
        inherit_vars(new_class, super_classes)
        inherit_fns(new_class, super_classes)
        setmetatable(new_class, {
            __index = function(self, key)
                -- 先在当前类中查找
                local v = rawget(self, key)
                if v then
                    return v
                end
                -- 然后在所有基类中查找
                for i, super_table in ipairs(self.super) do
                    v = super_classes[i][key]
                    if v then
                        return v
                    end
                end
                return nil
            end
        })
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

---@return __class
local function class(class_name)
    if internal_name[class_name] then
        -- todo zys
        -- log.error('class error: invalid class_name --- internal_name : ' .. class_name) ---@as _Class
        return
    end
    local new_class = {}
    local modifiers = {
        extends = function(self, ...)
            local super_class_names = {...}
            return function(subclass)
                local super_classes = {}
                for _, super_class_name in ipairs(super_class_names) do
                    local super_class = classes[super_class_name]
                    if not super_class then
                        -- todo zys log.error('class error : invalid super_class_name : ' .. super_class_name .. ', in class_name : ' .. class_name)
                        return nil
                    end
                    table.insert(super_classes, super_class)
                end

                local class_created = create_class(class_name, subclass, super_classes)
                return class_created
            end
        end
    }
    setmetatable(new_class, {
        __index = function(self, key)
            if modifiers[key] then
                return modifiers[key]
            end
            if classes[class_name] then
                return class[class_name][key]
            end
            -- todo zys  log.error("class error : class not found : " .. class_name)
        end,
        __call = function(self, ...)
            local new_inst = create_class(class_name, ...)
            return new_inst
        end
    })
    return new_class ---@as __class
end

local function new(class_name)
    return function(...)
        local classe = classes[class_name]
        if not classe then
            -- todo log.fatal(string.format('class2: class not found : %s !', tostring(class_name)))
            return
        end
        
        local new_obj = {}
        -- 复制类的属性到新对象
        for k, v in pairs(classe) do
            if inherit_reserved_keyword[k] then
                new_obj[k] = v
                goto continue
            end
            new_obj[k] = v
            ::continue::
        end
        
        -- 设置对象的元表以支持多继承方法查找
        setmetatable(new_obj, {
            __index = function(self, key)
                -- 先在对象自身查找
                local value = rawget(self, key)
                if value ~= nil then return value end
                
                -- 然后在类中查找
                value = classe[key]
                if value ~= nil then return value end
                
                return nil
            end
        })
        
        if new_obj.ctor then
            new_obj:ctor(...)
        end
        return new_obj
    end
end

-- 检查继承关系
local function deriveof(derive, base)
    if derive.__class_name == base.__class_name then
        return true
    end

    -- 检查直接基类
    if derive.__base_class_names then
        for _, base_name in ipairs(derive.__base_class_names) do
            if base_name == base.__class_name then
                return true
            end
        end
    end

    -- 递归检查所有基类
    if derive.super then
        for i, super_table in ipairs(derive.super) do
            local super_class = classes[derive.__base_class_names[i]]
            if super_class and deriveof(super_class, base) then
                return true
            end
        end
    end
    return false
end

local function instanceof(object, inclass)
    if not object or not object.__class_name then
        return false
    end
    local objClass = classes[object.__class_name]
    if not objClass then
        return false
    end
    local classClass = inclass
    if type(inclass) == "string" then
        classClass = classes[inclass]
    end
    return deriveof(objClass, classClass)
end

classes.new = new
classes.class = class
classes.deriveof = deriveof
classes.instanceof = instanceof

return classes