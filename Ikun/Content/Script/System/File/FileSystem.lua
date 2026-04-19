
---
---@brief   FileSystem
---@author  zys
---@data    Fri Jan 02 2026 22:32:27 GMT+0800 (中国标准时间)
---

local Class3 = require('Core/Class/Class3')
local log = require('Core/Log/log')
local FileContext = require('System/File/FileContext')

---@class FileSystem
local FileSystem = Class3.Class('FileSystem')

local StaticFileSystem = nil

---@private
function FileSystem:Ctor()
end

---@public
---@return FileSystem
function FileSystem.Get()
    if not StaticFileSystem then
        StaticFileSystem = FileSystem:New()
    end
    return StaticFileSystem
end

---@public
---@param InFilePath string
---@return string?
function FileSystem:MustReadSConfigFile(InFilePath)
    local fileContext = self:CreateConfigFileContext()
    if not fileContext then
        log.error('FileSystem:MustReadSConfigFile(): Failed to create FileContext!')
        return nil
    end

    local parts = {}
    for part in string.gmatch(InFilePath, "([^/]+)") do
        table.insert(parts, part)
    end

    local fileName = table.remove(parts)

    for _, dir in ipairs(parts) do
        if not fileContext:ChangeDirectory(dir) then
            log.error('FileSystem:MustReadSConfigFile(): Failed to change directory to [' .. dir .. ']!')
            return nil
        end
    end

    return fileContext:ReadStringFile(fileName)
end

---@public
---@todo 入参复用Context
---@return FileContextClass?
function FileSystem:CreateProjectFileContext() -- const
    local projDir = UE.UBlueprintPathsLibrary.ProjectDir()
    local pullDir = UE.UBlueprintPathsLibrary.ConvertRelativePathToFull(projDir)
    if not self:IsDirectoryExist(pullDir) then
        log.error('FileSystem:CreateProjectFileContext(): Failed to find project directory!')
        return nil
    end
    local context = FileContext:New(pullDir, self) ---@type FileContextClass
    return context
end

---@public
---@todo 入参复用Context
---@return FileContextClass?
function FileSystem:CreateConfigFileContext()
    local context = self:CreateProjectFileContext()
    if not context then
        return nil
    end
    if not context:ChangeDirectory('Content') then
        return nil
    end
    if not context:ChangeDirectory('Config') then
        return nil
    end
    return context
end

---@public
---@param InDirectory string
---@param InFileName string
function FileSystem:IsFileExists(InDirectory, InFileName)
    local fullPath = UE.UBlueprintPathsLibrary.Combine({InDirectory, InFileName})
    return UE.UBlueprintPathsLibrary.FileExists(fullPath)
end

---@public
---@param InDirectory string
---@return boolean
function FileSystem:IsDirectoryExist(InDirectory)
    return UE.UBlueprintPathsLibrary.DirectoryExists(InDirectory)
end

---@public
---@param InDirectory string
---@param InFileName string
---@return string?
function FileSystem:ReadStringFile(InDirectory, InFileName)
    local fullPath = UE.UBlueprintPathsLibrary.Combine({InDirectory, InFileName})
    local file, err = io.open(fullPath) ---@todo use LoadFileToString
    if not file then
        log.error('FileSystem:ReadStringFile(): Failed to open file: '..(err or 'unknown error'))
        return nil
    end
    local content = file:read('*a')
    file:close()
    return content
end

---@public
---@param InContext FileContextClass
function FileSystem:ReleaseContext(InContext)
end

return FileSystem