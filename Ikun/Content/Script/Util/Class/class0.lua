
log.info("全局class0使用")
--- # 深拷贝
---@param res table
---@return table
local function deepcopy(res)
    if type(res) == 'table' then
        local copy = {}
        for key, val in next, res, nil do
            copy[deepcopy(key)] = deepcopy(val)
        end
        setmetatable(copy, deepcopy(getmetatable(res)))
        return copy
    else -- number, string, boolean, etc
        return res
    end
end

--- # Search a value by key from a list of table
---@param supers table
---@param key any
---@return any
local function serach(supers, key)
    local bnil = true
    for _, _ in pairs(supers) do
        bnil = false
        break
    end
    if bnil then
        return nil
    end
    -- 在父类中寻找
    for _, super in pairs(supers) do
        local ret = rawget(super, key)
        if ret then
            return ret
        end
    end
    -- 找不到就去祖宗类里找
    for _, super in pairs(supers) do
        local ret = serach(super.super, key)
        if ret ~= nil then
            return ret
        end
    end
    return nil
end

--- # 纯虚方法
local function purevirtual()
    error("try to call pure virtual function !!!")
end

---@param vararg any 基类, 可多继承, 建议单继承 + Interface
local function create(...)
    local super = {}
    for _,sp in pairs(table.pack(...)) do
        if type(sp) == 'table' then
            table.insert(super, sp)
        end
    end
    -- if baseclass.isclass and baseclass:isclass() then
    --     super = {baseclass}
    -- elseif baseclass[1].isclass and baseclass[1]:isclass() then
    --     super = baseclass
    -- end

    local indexer = function(self, key)
        -- 当寻找方法时, 先找自己的
        -- local a = 1
        local ret = rawget(self, key) -- 这玩意会递归成环
        if ret ~= nil then
            return ret
        end
        -- 阻止搜索父类(super)的构造函数
        -- if key == 'ctor' then
        --     return nil
        -- end
        ret = nil
        if ret == nil and self.super then
            -- 最后再寻找父类中有没有
            ret = serach(self.super, key)
        end
        return ret
    end

    local newindexer = function(self, key, value)
        if key == 'new' then
            return
        end
        if key == 'ctor' then
            rawset(self, key, value)
            return
        end
        if rawget(self, key) then
            rawset(self, key, value)
            return
        elseif serach(self.super,key) then
            -- 存在于某个父类中
            for _,sp in pairs(self.super) do
                if sp[key] then
                    sp[key] = value
                    return
                end
            end
        end
        rawset(self, key, value)
    end

    local new = function(self, ...)
        local instance = deepcopy(self)

        for _, m in pairs(self) do
            if m == purevirtual then
                error("try to ctor abstract class !!!")
            end
        end

        -- setmetatable(instance, meta)

        if instance.ctor ~= nil and type(instance.ctor) == 'function' then
            instance:ctor(...)
        end

        return instance
    end

    local isclass = function() return true end

    setmetatable(super, {__index = function(self, key)
        local ret = serach(self, key)
        return ret
    end})
    
    -- 定义create的class
    local class = {
        super = super,
        new = new,
        isclass = isclass,
    }

    setmetatable(class, {
        __index = indexer,
        __newindex = newindexer
    })

    return class
end

return {
    create = create,
    purevirtual = purevirtual,
}