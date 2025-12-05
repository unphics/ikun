
---
---@brief   DirectoryDrowser
---@author  zys
---@data    Sun Aug 10 2025 15:04:15 GMT+0800 (中国标准时间)
---

---@class DirectoryBrowser
---@field private _CurPath string
local DirectoryBrowser = class.class 'DirectoryBrowser' {
    ctor = function()end,
    CreateProjDir = function()end,
    CreateConfigDir = function()end,
    ReadFile = function()end,
    GetCurPath = function()end,
    CD = function()end,
    _CurPath = '',
}

---@public 构造方法
function DirectoryBrowser:ctor()
end

---@static 从工程目录开始
---@return DirectoryBrowser
function DirectoryBrowser.CreateProjDir()
    local brs = class.new'DirectoryBrowser'() ---@as DirectoryBrowser
    local projDir = UE.UBlueprintPathsLibrary.ProjectDir()
    brs._CurPath = UE.UBlueprintPathsLibrary.ConvertRelativePathToFull(projDir)
    return brs
end

---@static 从配置表目录开始
---@return DirectoryBrowser
function DirectoryBrowser.CreateConfigDir()
    local brs = DirectoryBrowser.CreateProjDir()
    brs:CD('..')
    brs:CD("Config")
    return brs
end

---@public 读取当前目录下的文件
---@param InFileName string
---@return string
function DirectoryBrowser:ReadFile(InFileName)
    local fullPath = UE.UBlueprintPathsLibrary.Combine({self._CurPath, InFileName})
    local file, err = io.open(fullPath) ---@todo use LoadFileToString
    if not file then
        log.error('DirectoryBrowser: failed to open file: ' .. (err or 'unknown error'))
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

---@public 获取当前路径
function DirectoryBrowser:GetCurPath()
    return self._CurPath
end

---@public
---@param InDirName string
---@return boolean
function DirectoryBrowser:CD(InDirName)
    local targetPath
    if InDirName == '..' then
        local pathWithDotDot = UE.UBlueprintPathsLibrary.Combine({self._CurPath, ".."})
        local _, parentPath = UE.UBlueprintPathsLibrary.CollapseRelativeDirectories(pathWithDotDot)
        if parentPath == self._CurPath or parentPath == (self._CurPath .. "/") then
            log.error('DirectoryBrowser:CD() Already at root')
            return false
        end
        targetPath = parentPath
    else
        local combinePath = UE.UBlueprintPathsLibrary.Combine({self._CurPath, InDirName})
        local _, newPath = UE.UBlueprintPathsLibrary.CollapseRelativeDirectories(combinePath)

        if not UE.UBlueprintPathsLibrary.DirectoryExists(newPath) then
            log.error('DirectoryBrowser:CD() directory not exist: \''..InDirName..'\'')
            return false
        end
        targetPath = newPath
    end
    
    self._CurPath = targetPath
    return true
end