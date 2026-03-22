
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 字符串处理工具集
--  File        : StrUtils.lua
--  Author      : zhengyanshuai
--  Date        : Sat Oct 11 2025 17:50:27 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local log =  require("Core/Log/log")

---@class StrUtils
local StrUtils = {}

---@public 通过逗号拆解字符串为数组
---@todo 是否需要尝试转数字
---@param InStr string
---@return string[]
StrUtils.ParseArrayByComma = function(InStr)
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

---@public 通过逗号拆解字符串为字典
---@todo 是否需要尝试转数字
---@param InStr string
---@return table<string, string>
StrUtils.ParseDictByComma = function(InStr)
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

--------------------------------------------------------------------------------------------------------------------------------

---@public 字符串分割, 忽略空元素
---@param InStr string
---@param InDelimiter string
---@return string[]
StrUtils.SplitSimple = function(InStr, InDelimiter)
    if not InDelimiter then
        log.fatal('无效的分隔符')
    end
    if not InStr or InStr == '' then
        return {}
    end
    local result = {}
    for item in InStr:gmatch("([^"..InDelimiter.."]+)") do
        local num = tonumber(item)
        table.insert(result, num or item)
    end
    return result
end

---@public 字符串分割, 保留空元素
---@param InStr string
---@param InDelimiter string
---@return string[]
StrUtils.SplitExact = function(InStr, InDelimiter)
    if not InDelimiter then
        log.fatal('无效的分隔符')
    end
    if not InStr or InStr == '' then
        return {}
    end
    local strStart = 1
    local strLen = #InStr
    local result = {}
    while strStart <= strLen do
        local nextPos = InStr:find(InDelimiter, strStart, true)
        local item = nil
        if not nextPos then
            item = InStr:sub(strStart)
            strStart = strLen + 1
        else
            item = InStr:sub(strStart, nextPos - 1)
            strStart = nextPos + 1
        end
        table.insert(result, item)
    end
    return result
end

---@public 判断为空
---@return boolean
StrUtils.IsEmpty = function(InStr)
    if not InStr or InStr == '' or InStr == ' ' then
        return true
    end
    return false
end

---@public 去掉空格, 排查字符串中前两个字符和后两个字符
---@param InStr string
---@return string
StrUtils.Trim = function(InStr)
    if type(InStr) ~= 'string' then
        return InStr
    end

    local len = #InStr
    local start = 1
    local finish = len

    if InStr:byte(1) == 32 then
        start = InStr:byte(2) == 32 and 3 or 2
    end

    if InStr:byte(len) == 32 then
        finish = InStr:byte(len - 1) == 32 and len - 2 or len - 1
    end

    local result = InStr:sub(start, finish)
    return result and result ~= '' and result or nil
end

return StrUtils