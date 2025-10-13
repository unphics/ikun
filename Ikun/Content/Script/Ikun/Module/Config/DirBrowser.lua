
---
---@brief   目录浏览
---@author  zys
---@data    Sun Aug 10 2025 15:04:15 GMT+0800 (中国标准时间)
---

---@class DirBrowser
---@field cur_path string
local DirBrowser = class.class 'DirBrowser' {
--[[static]]
    create_proj_dir = function()end,
    create_cfg_dir = function()end,
--[[public]]
    ctor = function()end,
    read_file = function()end,
    get_cur_path = function()end,
    cd = function()end,
    up = function()end,
--[[private]]
    normalize_path = function()end,
    cur_path = nil,
}

---@static
---@return DirBrowser
function DirBrowser.create_proj_dir()
    local brs = class.new'DirBrowser'() ---@as DirBrowser
    brs.cur_path = UE.UKismetSystemLibrary.GetProjectDirectory()
    return brs
end

---@static
---@return DirBrowser
function DirBrowser.create_cfg_dir()
    local brs = DirBrowser.create_proj_dir()
    brs:up()
    brs:cd("Config")
    return brs
end

---@public
function DirBrowser:ctor()
end

---@public 读取当前目录下的文件
---@return string
function DirBrowser:read_file(file_name)
    local file, err = io.open(self.cur_path .. '/' .. file_name)
    if not file then
        log.error('failed to open file: ' .. (err or 'unknown error'))
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

---@public 获取当前路径
function DirBrowser:get_cur_path()
    return self.cur_path
end

---@public
---@param dir_name string
---@return boolean
function DirBrowser:cd(dir_name)
    if dir_name == '..' then
        return self:up()
    end
    local new_path = self:normalize_path(self.cur_path .. '/' .. dir_name)
    if not UE.UBlueprintPathsLibrary.DirectoryExists(new_path) then
        log.error('DirBrowser:cd() directory not exist: \''..dir_name..'\'')
        return false
    end
    
    self.cur_path = new_path
    return true
end

---@public 跳到上一级路径
---@return boolean
function DirBrowser:up()
    -- 先去除末尾的斜杠（如果有的话）
    local clean_path = self.cur_path:gsub("/+$", "")
    -- 然后进行父路径匹配
    local parent_path = clean_path:match("^(.*)/[^/]*$")
    -- 特殊处理Windows盘符根目录（如"D:"）
    if not parent_path and clean_path:match("^%a:$") then
        log.error('DirBrowser:up() already at drive root')
        return false
    elseif not parent_path then
        log.error('DirBrowser:up() already at root dir')
        return false
    end
    -- 确保父路径不以斜杠结尾（除了盘符根目录）
    parent_path = parent_path:gsub("/+$", "")
    if parent_path:match("^%a:$") then
        parent_path = parent_path .. "/"  -- Windows盘符根目录保持"D:/"形式
    end
    self.cur_path = parent_path
    return true
end

---@private 路径规范化(统一使用正斜杠)
---@param path string
---@return string
function DirBrowser:normalize_path(path)
    path = path:gsub("\\", "/")
    path = path:gsub("/+$", "")
    return path
end