
--[[
-- -----------------------------------------------------------------------------
--  Brief       : LuaTableUtils
--  File        : TableUtils.lua
--  Author      : zhengyanshuai
--  Date        : Sun May 04 2025 14:15:45 GMT+0800 (中国标准时间)
--  Description : 表工具方法
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

---@class TableUtils
local TableUtils = {}

---@public 浅拷贝, 拷一层
---@param Table table
TableUtils.ShallowCopy = function(Table)
    local tb = {}
    for i, ele in pairs(Table) do
        tb[i] = ele
    end
    return tb
end

---@public 深拷贝
---@param Table table
TableUtils.DeepCopy = function(Table)
    local tb = {}
    for k, v in pairs(Table) do
        if type(v) == "table" then
            tb[k] = TableUtils.DeepCopy(v)
        else
            tb[k] = v
        end
    end
    return tb
end

---@public 判断表是数组
---@param InTable table
---@return boolean
TableUtils.IsArray = function(InTable)
    if not InTable and type(InTable) ~= "table" then
        return false
    end
    for _, _ in ipairs(InTable) do
        return true
    end
    return false
end

---@public 判断表是字典
---@param InTable table
---@return boolean
TableUtils.IsDict = function(InTable)
    if not InTable and type(InTable) ~= "table" then
        return false
    end
    for _,_ in ipairs(InTable) do
        return false
    end
    return (next(InTable) ~= nil) and true or false
end

---@public 构造一个数组
---@param InLength integer
---@param InDefaultValue any @[opt]
---@return table
TableUtils.MakeArray = function(InLength, InDefaultValue)
    if not InLength or type(InLength) ~= "number" or InLength < 1 then
        return {}
    end
    InDefaultValue = InDefaultValue or false
    local tb = {}
    for i = 1, InLength do
        table.insert(tb, InDefaultValue)
    end
    return tb
end

---@public 获取字典的长度
---@param InTable table
---@return integer
TableUtils.DictLength = function(InTable)
    if not InTable or type(InTable) ~= "table" then
        return 0
    end
    local len = 0
    for _ in pairs(InTable) do
        len = len + 1
    end
    return len
end

---@public
---@param InTable table
---@param InFn fun(InItem):boolean
TableUtils.FindIf = function(InTable, InFn)
    for i = 1, #InTable do
        if InFn(InTable[i]) then
            return InTable[i]
        end
    end
end

---@public
---@param InTable table
TableUtils.RemoveValue = function(InTable, InItem)
    for i = 1, #InTable do
        if InTable[i] == InItem then
            table.remove(InTable, i)
            break
        end
    end
end

---@public
---@param InTable table
---@param InItem any
TableUtils.AddUnique = function(InTable, InItem)
    for i = 1, #InTable do
        if InTable[i] == InItem then
            return
        end
    end
    table.insert(InTable, InItem)
end

---@public
---@param InTable table
---@param InFn fun(InItem):boolean
---@return any
TableUtils.RemoveIf = function(InTable, InFn)
    for i = 1, #InTable do
        if InFn(InTable[i]) then
            return table.remove(InTable, i)
        end
    end
end

return TableUtils