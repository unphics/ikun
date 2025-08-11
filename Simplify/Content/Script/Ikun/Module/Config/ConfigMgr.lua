---
---@brief   配置管理器
---@author  zys
---@data    Sun Aug 10 2025 01:30:39 GMT+0800 (中国标准时间)
---

require('Ikun/Module/Config/DirBrowser')

local PreLoadConfig = {'Effect', 'Talk'}

---@class ConfigMgr : MdBase
---@field CachedConfigTable table<string, table>
local ConfigMgr = class.class 'ConfigMgr':extends 'MdBase' {
    --[[public]]
    ctor = function() end,
    Init = function()end,
    GetConfig = function()end,
    LoadConfigTable = function()end,
    --[[private]]
    ParsePipeTable = function() end,
    CachedConfigTable = nil,
}
---@override
function ConfigMgr:ctor()
    log.info('ConfigMgr:ctor()')

    self.CachedConfigTable = {}
end

---@override
function ConfigMgr:Init()
    local brs = class.DirBrowser.create_cfg_dir()
    for _, name in ipairs(PreLoadConfig) do
        if self:LoadConfigTable(brs, name) then
            log.info('ConfigMgr:Init()', 'preload config table named:', name)
        else
            log.error('ConfigMgr:Init()', 'Failed to load config table named:', name)
        end
    end
    log.info('ConfigMgr:Init(): all pre load config table has already loaded !')
end

---@public
---@param Name string
function ConfigMgr:GetConfig(Name)
    return self.CachedConfigTable[Name]
end

---@public
---@param Drs DirBrowser
---@param FileName string
function ConfigMgr:LoadConfigTable(Drs, FileName)
    -- local brs = class.DirBrowser.create_cfg_dir() ---@as DirBrowser
    local content = Drs:read_file(FileName .. '.csv')
    local cfg = self:ParsePipeTable(content)
    self.CachedConfigTable[FileName] = cfg
    return cfg
end

---@private 解析以"|"为分隔符的csv表格内容
---@param data string
---@param key_col_index number
---@return table
function ConfigMgr:ParsePipeTable(data, key_col_index)
    key_col_index = key_col_index or 1
    local parseResult = {}
    local header = nil -- 表头数组
    local line_num = 0

    -- 辅助函数：解析逗号分隔的值为数组
    local function parse_array(str)
        if not str or str == "" then return nil end
        local arr = {}
        for item in str:gmatch("([^,]+)") do
            -- 尝试转数字
            local num = tonumber(item)
            table.insert(arr, num or item)
        end
        return #arr > 0 and arr or nil
    end

    -- 辅助函数：解析键值对为字典
    local function parse_dict(str)
        if not str or str == "" then return nil end
        local dict = {}
        for pair in str:gmatch("([^,]+)") do
            local key, value = pair:match("^([^=]+)=([^=]+)$")
            if key and value then
                -- 尝试转数字
                local num = tonumber(value)
                dict[key] = num or value
            end
        end
        return next(dict) and dict or nil
    end

    for line in data:gmatch("[^\r\n]+") do
        line_num = line_num + 1
        local row = {}
        local start = 1
        local len = #line
        local col = 1
        local skip = false

        if not header then
            -- 读取表头，按管道符分割
            header = {}
            while start <= len do
                local next_pipe = line:find("|", start, true)
                local field
                if not next_pipe then
                    field = line:sub(start)
                    start = len + 1
                else
                    field = line:sub(start, next_pipe - 1)
                    start = next_pipe + 1
                end
                table.insert(header, field)
            end
        else
            -- 读取数据行
            while start <= len do
                local next_pipe = line:find("|", start, true)
                local field
                if not next_pipe then
                    field = line:sub(start)
                    start = len + 1
                else
                    field = line:sub(start, next_pipe - 1)
                    start = next_pipe + 1
                end

                -- 用表头的字段名做 key
                local key = header[col] or ("unknown_col_" .. col)

                -- 尝试解析为数组或字典
                if field and field ~= "" then
                    if field:find(",") then
                        -- 如果有逗号，尝试解析为数组或字典
                        if field:find("=") then
                            -- 如果有等号，解析为字典
                            row[key] = parse_dict(field)
                        else
                            -- 没有等号，解析为数组
                            row[key] = parse_array(field)
                        end
                    else
                        -- 没有逗号，尝试解析为键值对或普通值
                        if field:find("=") then
                            local k, v = field:match("^([^=]+)=([^=]+)$")
                            if k and v then
                                row[key] = { [k] = tonumber(v) or v }
                            else
                                row[key] = field
                            end
                        else
                            -- 尝试转数字
                            local num = tonumber(field)
                            row[key] = num or field
                        end
                    end
                else
                    row[key] = nil
                end

                -- 判断主键列是否为空，空则跳过整行
                if col == key_col_index and (row[key] == nil or row[key] == "") then
                    skip = true
                end

                col = col + 1
            end

            if not skip then
                local mainKey = header[key_col_index]
                local mainKeyVal = row[mainKey]
                if mainKeyVal then
                    parseResult[mainKeyVal] = row
                end
                -- table.insert(parseResult, row)
            end
        end
    end

    return parseResult
end

return ConfigMgr