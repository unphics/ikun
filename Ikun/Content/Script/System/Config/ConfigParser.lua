
---
---@brief   ConfigParserClass
---@author  zys
---@data    Sat Jan 03 2026 00:20:02 GMT+0800 (中国标准时间)
---

local log =  require("Core/Log/log")
local Class3 = require("Core/Class/Class3")
local StrUtils = require("Core/Utils/StrUtils")
local IConfigParser = require("System/Config/Interface").IConfigParser

---@class ConfigParserClass: IConfigParser
---@field _System ConfigSystem
local ConfigParserClass = Class3.Class('ConfigParserClass', IConfigParser)

---@public
---@param InConfigStr string
---@param InConfigSystem ConfigSystem
function ConfigParserClass:Ctor(InConfigStr, InConfigSystem)
    self._System = InConfigSystem
    self._Header = {}
    self._Data = InConfigStr
end

---@public 转为行数组
---@return ConfigParserClass
function ConfigParserClass:ToRows(InSeparator)
    InSeparator = InSeparator or '\r\n'
    self._Data = StrUtils.SplitSimple(self._Data, InSeparator)
    return self
end

---@public 识别表头
---@return ConfigParserClass
function ConfigParserClass:ExtractHeaders(InRowNum, InSeparator)
    InRowNum = InRowNum or 1
    InSeparator = InSeparator or '|'
    local headerStr = table.remove(self._Data, InRowNum)
    self._Header = StrUtils.SplitExact(headerStr, InSeparator)
    return self
end

---@public
---@return ConfigParserClass
function ConfigParserClass:ToGrid(InSeparator)
    InSeparator = InSeparator or '|'
    for i, str in ipairs(self._Data) do
        self._Data[i] = StrUtils.SplitExact(str, InSeparator)
    end
    return self
end

---@public
---@return ConfigParserClass
function ConfigParserClass:ToMap(InPrimaryCol)
    InPrimaryCol = InPrimaryCol or 1
    local resultMap = {}
    for _, cells in ipairs(self._Data) do
        if not StrUtils.IsEmpty(cells[InPrimaryCol]) then
            local rowMap = {}
            for j, key in ipairs(self._Header) do
                if not StrUtils.IsEmpty(cells[j]) then
                    rowMap[key] = tonumber(cells[j]) or cells[j] ---@warn 此处默认做tonumber处理
                end
            end
            local mainKey = cells[InPrimaryCol]
            resultMap[mainKey] = tonumber(rowMap) or rowMap ---@warn 此处默认做tonumber处理
        end
    end
    self._Data = resultMap
    return self
end

---@public
---@param InHeaders string[]
---@return ConfigParserClass
function ConfigParserClass:CastNumCol(InHeaders)
    for _, row in pairs(self._Data) do
        for _, name in ipairs(InHeaders) do
            local gridStr = row[name]
            if gridStr then
                row[name] = tonumber(gridStr)
            end
        end
    end
    return self
end

---@public
---@param InHeaders string[]
---@return ConfigParserClass
function ConfigParserClass:CastMapCol(InHeaders)
    for _, row in pairs(self._Data) do
        for _, name in ipairs(InHeaders) do
            local gridStr = row[name]
            if gridStr then
                local arr = StrUtils.SplitSimple(gridStr, ',')
                local gridData = {}
                for _, pair in ipairs(arr) do
                    local key, value = pair:match("^([^=]+)=([^=]+)$")
                    if not StrUtils.IsEmpty(value) then
                        key = StrUtils.Trim(key)
                        value = StrUtils.Trim(value)
                        gridData[key] = tonumber(value) or value
                    end
                end
                row[name] = gridData
            end
        end
    end
    return self
end

---@public
---@param InHeaders string[]
---@return ConfigParserClass
function ConfigParserClass:CastArrCol(InHeaders)
    for _, row in pairs(self._Data) do
        for _, name in ipairs(InHeaders) do
            local gridStr = row[name]
            if gridStr then
                local arr = StrUtils.SplitSimple(gridStr, ',')
                local gridData = {}
                for _, item in ipairs(arr) do
                    local ele = StrUtils.Trim(item)
                    table.insert(gridData, tonumber(ele) or ele)
                end
                row[name] = gridData
            end
        end
    end
    return self
end

---@public
---@param InHeaders string[]
---@return ConfigParserClass
function ConfigParserClass:CastPairCol(InHeaders)
    for _, row in pairs(self._Data) do
        for _, name in ipairs(InHeaders) do
            local gridStr = row[name]
            if not StrUtils.IsEmpty(gridStr) then
                local key, value = gridStr:match("^([^=]+)=([^=]+)$")
                key = StrUtils.Trim(key)
                value = StrUtils.Trim(value)
                row[key] = tonumber(value) or value
            end
        end
    end
    return self
end

---@public
---@param InHeaders string[]
---@return ConfigParserClass
function ConfigParserClass:CastBoolCol(InHeaders)
    for _, row in pairs(self._Data) do
        for _, name in ipairs(InHeaders) do
            local gridStr = row[name]
            if not StrUtils.IsEmpty(gridStr) then
                if gridStr == "true" then
                    row[name] = true
                elseif gridStr == "false" then
                    row[name] = false
                else
                    row[name] = false
                end
            end
        end
    end
    return self
end

---@public
---@return any
function ConfigParserClass:GetResult()
    return self._Data
end

function ConfigParserClass:ReleaseParser()
    local system = self._System
    self._System = nil
    self._Data = nil
    self._Header = nil
    system:ReleaseParser(self)
end

return ConfigParserClass