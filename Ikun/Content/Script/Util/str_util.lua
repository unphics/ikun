
---
---@brief   字符串处理工具
---@author  zys
---@data    Sat Oct 11 2025 17:50:27 GMT+0800 (中国标准时间)
---

---@class str_util
local str_util = {}

---@public
---@todo 是否需要尝试转数字
---@param InStr string
---@return string[]
str_util.parse_array_by_comma = function(InStr)
    if not InStr or InStr == '' then
        return {}
    end
    local result = {}
    for item in InStr:gmatch("([^,]+)") do
        local num = tonumber(item)
        table.insert(result, num or item)
    end
    return result
end

---@public
---@todo 是否需要尝试转数字
---@param InStr string
---@return table<string, string>
str_util.parse_dict_by_comma = function(InStr)
    if not InStr or InStr == '' then
        return {}
    end
    local result = {}
    ---@param pair string
    for pair in InStr:gmatch("([^,]+)") do
        local key, value = pair:match("^([^=]+)=([^=]+)$")
        if key and value then
            local num = tonumber(value)
            result[key] = num or value
        end
    end
    return result
end

return str_util