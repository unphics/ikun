
---
---@brief   FileContext
---@author  zys
---@data    Fri Jan 02 2026 22:35:46 GMT+0800 (中国标准时间)
---

local Class3 = require('Core/Class/Class3')
local IFileContext = require('System/File/Interface').IFileContext

---@class FileContextClass: IFileContext
---@field _System FileSystem
---@field _CurrentDirectory string
local FileContextClass = Class3.Class('FileContextClass', IFileContext)

---@public
---@param InSystem FileSystem
function FileContextClass:Ctor(InitDirectory, InSystem)
    self._CurrentDirectory = InitDirectory
    self._System = InSystem
end

---@public
---@param InDirectory string
---@return boolean
function FileContextClass:ChangeDirectory(InDirectory)
    local target
    if InDirectory == '..' then
        local pathWithDotDot = UE.UBlueprintPathsLibrary.Combine({self:GetCurrentDirectory(), ".."})
        local _, parentPath = UE.UBlueprintPathsLibrary.CollapseRelativeDirectories(pathWithDotDot)
        if parentPath == self:GetCurrentDirectory() or (parentPath == (self:GetCurrentDirectory()..'/')) then
            log.error('FileContextClass:ChangeDirectory()": Already at root')
            return false
        end
        target = parentPath
    else
        local combinePath = UE.UBlueprintPathsLibrary.Combine({self:GetCurrentDirectory(), InDirectory})
        local _, newPath = UE.UBlueprintPathsLibrary.CollapseRelativeDirectories(combinePath)
        if not UE.UBlueprintPathsLibrary.DirectoryExists(newPath) then
            log.error('FileContextClass:ChangeDirectory: Directory not exist: '..combinePath)
            return false
        end
        target = newPath
    end
    self._CurrentDirectory = target
    return true
end

---@public
---@param InFileName string
---@return string?
function FileContextClass:ReadStringFile(InFileName)
    return self._System:ReadStringFile(self:GetCurrentDirectory(), InFileName)
end

---@public
---@return string?
function FileContextClass:GetCurrentDirectory()
    return self._CurrentDirectory
end

---@public
function FileContextClass:ReleaseContext()
    local system = self._System
    self._System = nil
    self._CurrentDirectory = nil
    system:ReleaseContext(self)
end

return FileContextClass