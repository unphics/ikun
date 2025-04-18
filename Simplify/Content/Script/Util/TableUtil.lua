
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