---
---@brief   配置管理器
---@author  zys
---@data    Sun Aug 10 2025 01:30:39 GMT+0800 (中国标准时间)
---

require('Ikun/Module/Config/DirBrowser')

---@class ConfigMgr
---@field _CachedConfigTable table<string, table>
local ConfigMgr = class.class 'ConfigMgr' {
    --[[public]]
    ctor = function() end,
    GetConfig = function()end,
    LoadConfigTable = function()end,
    GetGlobalConst = function()end,    
--[[private]]
    _PreloadConfigTable = function()end,
    _ParsePipeTable = function()end,
    _CachedConfigTable = nil,
}

---@override 初始化缓存容器, 加载需要预加载的配置表
function ConfigMgr:ctor()
    log.info('ConfigMgr:ctor()')

    self._CachedConfigTable = {}
    self:_PreloadConfigTable()
end

---@public 读取配置表
---@param Name string
---@return table
function ConfigMgr:GetConfig(Name)
    return self._CachedConfigTable[Name]
end

---@public 通过目录和文件名加载配置表并缓存
---@param Drs DirBrowser
---@param FileName string
function ConfigMgr:LoadConfigTable(Drs, FileName)
    -- local brs = class.DirBrowser.create_cfg_dir() ---@as DirBrowser
    if FileName == 'Role' then
        local a = 1
    end
    local content = Drs:read_file(FileName .. '.csv')
    local cfg = self:_ParsePipeTable(content)
    self._CachedConfigTable[FileName] = cfg
    return cfg
end

---@public 获取全局控制值
---@param Name string
---@return number|string
function ConfigMgr:GetGlobalConst(Name)
    local row = self._CachedConfigTable.GlobalConst[Name]
    return row and row.Value
end

---@private 预加载一些配置表
function ConfigMgr:_PreloadConfigTable()
    log.info('ConfigMgr:_PreloadConfigTable()', '预加载配置表开始!')

    local brs = class.DirBrowser.create_cfg_dir() ---@type DirBrowser
    self:LoadConfigTable(brs, 'GlobalConst')
    local preloadConfig = self:LoadConfigTable(brs, 'Preload')

    for dirName, tables in pairs(preloadConfig) do
        if brs:cd(dirName) then
            local tableIndex = 1
            local cfgTableHead = 'Table'
            while tables[cfgTableHead..tableIndex] do
                local tableName = tables[cfgTableHead..tableIndex]
                if tableName then
                    if self:LoadConfigTable(brs, tableName) then
                        log.info('ConfigMgr:_PreloadConfigTable()', '加载成功:', tableName)
                    else
                        log.error('ConfigMgr:_PreloadConfigTable()', '加载失败:', tableName)
                    end
                end
                tableIndex = tableIndex + 1
            end
            brs:up()
        end
    end
    log.info('ConfigMgr:_PreloadConfigTable()', '预加载配置表结束!')
end

---@private 解析以"|"为分隔符的csv表格内容
---@param InData string
---@param InMajorKeyColIdx number 主键所在的列
---@return table
function ConfigMgr:_ParsePipeTable(InData, InMajorKeyColIdx)
    InMajorKeyColIdx = InMajorKeyColIdx or 1
    local parseResult = {}
    local header = nil -- 表头数组
    
    local allLineData = {} -- 所有的行
    for line in InData:gmatch("[^\r\n]+") do
        table.insert(allLineData, line)
    end
    local rowCount = #allLineData

    for line in InData:gmatch("[^\r\n]+") do
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
                            row[key] = str_util.parse_dict_by_comma(field)
                        else
                            -- 没有等号，解析为数组
                            row[key] = str_util.parse_array_by_comma(field)
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
                if col == InMajorKeyColIdx and (row[key] == nil or row[key] == "") then
                    skip = true
                end

                col = col + 1
            end

            if not skip then
                local mainKey = header[InMajorKeyColIdx]
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