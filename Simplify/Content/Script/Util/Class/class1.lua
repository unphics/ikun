
log.info("全局class1使用")

local classes = {}
local interfaces = {}

local function tb_copy(t, st)
    local tb = {}
    for i, v in pairs(t) do
        if (not tb[i]) then
            tb[i] = v
        end
    end
    if st then
        tb.super = st
        tb.base_class_name = st.__name
        setmetatable(tb, {__index = tb.super})
        -- setmetatable(tb, {__index = function(self, key)
        --     log.warn("zys ___333", key)
        -- end})
    end
    return tb
end

local function tb_impl(t, t2)
    local tb = {}
    for k, v in ipairs(t2) do
        t[#t+1] = v
    end
    tb = tb_copy(t)
end

local function create_class(class_name, structure, super_class)
    if (classes[class_name]) then
        log.info("class error : class \"" .. class_name .. "\" already exists.")
    end
    local new_class = structure
    new_class.__name = class_name
    if super_class then
        new_class.super = super_class
        new_class.base_class_name = super_class.__name
        setmetatable(new_class, {__index = super_class})
        -- setmetatable(new_class, {__index = function(self, key)
        --     log.warn("zys __222", key)
        -- end})
    end
    classes[class_name] = new_class
    return new_class
end

local function interface(interface_name)
    local new_interface = {}
    setmetatable(new_interface, {
        __call = function (self, ...)
            if interfaces[interface_name] then
                log.error("class error : interface \"" .. interface_name "\" already exist.")
            end
            interfaces[interface_name] = new_interface
            return new_interface
        end
    })
    new_interface.extends = function(self, super_interface_name)
        return function(sub_interface)
            local super_interface = interfaces[super_interface_name]
            local new_inst = tb_impl(sub_interface, super_interface)
            if interfaces[interface_name] then
                log.error("class error : interface \"" .. interface_name "\" already exist.")
            end
            interfaces[interface_name] = new_inst
            return new_inst
        end
    end
    return new_interface
end

local function class(class_name)
    local new_class = {}
    local modifiers = {
        extends = function(self, super_class_name)
            return function(subclass)
                local super_class = classes[super_class_name]
                local class_created = create_class(class_name, subclass, super_class)
                return class_created
            end
        end,
        implements = function (self, ...)
            local interfaces_names = {...}
            return function(subclass)
                local class_created = create_class(class_name, subclass)
                for _, v in pairs(interfaces_names) do
                    if not interfaces[v] then
                        log.error("class error : interface \"" .. v .. "\" not found")
                    end
                    for _, method in pairs(interfaces[v]) do
                        if not subclass[method] then
                            log.error("class error : interface \"" .. v "\" not implemented, method \"" .. method .. "\" not found")
                        end
                    end
                end
                return class_created
            end
        end
    }
    setmetatable(new_class, {
        __index = function(self, key)
            -- log.warn("zys __ 111", key) key = extends
            if modifiers[key] then
                return modifiers[key]
            end
            if classes[class_name] then
                return classes[class_name][key]
            end
            log.error("class error : class \"" .. class_name .. "\" not found")
        end,
        __call = function(self, ...)
            if classes[class_name] then
                log.info("class error : class \"" .. class_name .. "\" already exist")
            end
            local new_inst = create_class(class_name, ...)
            return new_inst
        end
    })
    return new_class
end

local function new(class_name)
    return function(...)
        local classe = classes[class_name]
        if not classe then
            log.error("class error : class \"" .. class_name .. "\" not found")
        end
        local super = classe.super
        local new_obj = tb_copy(classe, super)
        if new_obj.ctor then
            new_obj:ctor(...)
        end
        return new_obj
    end
end

local function derivedfrom(instance, class_name)
    local class = classes[class_name]
    if not class then
        log.error("class error : class \"" .. class_name .. "\" not found")
    end
    if instance and class_name == instance.base_class_name then
        return true
    end
    return false
end

local function instanceof(instance, class_name)
    local classe = classes[class_name]
    if not classe then
        log.error("class error : class \"" .. class_name .. "\" not found")
    end
    if instance.__name == class_name then
        return true
    end
    return false
end

return {
    interface = interface,
    class = class,
    new = new,
    derivedfrom = derivedfrom,
    instanceof = instanceof,
}