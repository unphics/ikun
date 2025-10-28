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
    local allLineData = str_util.split_simple(InData, '\r\n') -- 所有的行
    local result = {}
    local headerData = str_util.split_exact(allLineData[1], "|") -- 表头数组
    for rowNum, rowStr in ipairs(allLineData) do
        rowStr = str_util.trim(rowStr)
        if rowNum == 1 then
            goto next_row
        end
        
        local rowData = str_util.split_exact(rowStr, '|')
        
        local majorKeyContent = rowData[InMajorKeyColIdx]
        if not majorKeyContent or majorKeyContent == '' or majorKeyContent:find(',') then
            goto next_row
        end

        local rowResult = {}
        for headerNum, headerName in ipairs(headerData) do
            local itemStr = rowData[headerNum]
            if not itemStr or itemStr == '' then
                goto  next_item
            end
            headerName = str_util.trim(headerName)
            if itemStr:find(',') and itemStr:find('=') then -- 字典
                local arr = str_util.split_simple(itemStr, ',')
                rowResult[headerName] = {}
                for _, pair in ipairs(arr) do
                    local key, value = pair:match("^([^=]+)=([^=]+)$")
                    key = str_util.trim(key)
                    value = str_util.trim(value)
                    if key then
                        rowResult[headerName][key] = tonumber(value) or value
                    end
                end
            elseif itemStr:find(',') then -- 数组
                rowResult[headerName] = {}
                local arr = str_util.split_simple(itemStr, ',')
                for _, item in ipairs(arr) do
                    table.insert(rowResult[headerName], str_util.trim(item))
                end
            elseif itemStr:find('=') then -- 单键值对
                local key, value = itemStr:match("^([^=]+)=([^=]+)$")
                rowResult[headerName] = { [key] = tonumber(value) or value }
            else -- 普通的值
                rowResult[headerName] = tonumber(itemStr) or itemStr
            end
            ::next_item::
        end
        local majorKey = tonumber(majorKeyContent) or majorKeyContent
        result[majorKey] = rowResult
        ::next_row::
    end
    return result
end

return ConfigMgr