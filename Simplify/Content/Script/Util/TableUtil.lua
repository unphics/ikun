---
---@brief lua的表工具
---@author zys
---@data Sun May 04 2025 14:15:45 GMT+0800 (中国标准时间)
---

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

return table_util