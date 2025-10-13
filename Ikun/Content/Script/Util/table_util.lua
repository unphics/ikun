
---
---@brief   lua的表工具
---@author  zys
---@data    Sun May 04 2025 14:15:45 GMT+0800 (中国标准时间)
---

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

---@public
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

return table_util