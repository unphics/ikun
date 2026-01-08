
--[[
-- -----------------------------------------------------------------------------
--  Brief       : LuaTableUtil
--  File        : table_util.lua
--  Author      : zhengyanshuai
--  Date        : Sun May 04 2025 14:15:45 GMT+0800 (中国标准时间)
--  Description : 表工具方法
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

---@class table_util
local table_util = {}

---@public 浅拷贝, 拷一层
---@param Table table
table_util.shallow_copy = function(Table)
    local tb = {}
    for i, ele in pairs(Table) do
        tb[i] = ele
    end
    return tb
end

---@public 深拷贝
---@param Table table
table_util.deep_copy = function(Table)
    local tb = {}
    for k, v in pairs(Table) do
        if type(v) == "table" then
            tb[k] = table_util.deep_copy(v)
        else
            tb[k] = v
        end
    end
    return tb
end

---@public 获取字典的长度
---@param Table table
---@return number
table_util.map_len = function(Table)
    local len = 0
    for _ in pairs(Table) do
        len = len + 1
    end
    return len
end

---@public
---@param InTable table
---@param InFn fun(InItem):boolean
table_util.find_if = function(InTable, InFn)
    for i = 1, #InTable do
        if InFn(InTable[i]) then
            return InTable[i]
        end
    end
end

---@public
---@param InTable table
---@param InFn fun(InItem):boolean
table_util.remove = function(InTable, InItem)
    for i = 1, #InTable do
        if InTable[i] == InItem then
            table.remove(InTable, InItem)
        end
    end
end

---@public
---@param InTable table
---@param InItem any
table_util.add_unique = function(InTable, InItem)
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
table_util.remove_if = function(InTable, InFn)
    for i = 1, #InTable do
        if InFn(InTable[i]) then
            return table.remove(InTable, i)
        end
    end
end

return table_util