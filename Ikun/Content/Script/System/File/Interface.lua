
local Class3 = require('Core/Class/Class3')

---@class IFileSystem
local IFileSystem = Class3.Interface('IFileSystem')

function IFileSystem.Get() Class3.Abstract() end
function IFileSystem:CreateProjectContext() Class3.Abstract() end
function IFileSystem:CreateConfigContext() Class3.Abstract() end
function IFileSystem:ReadStringFile() Class3.Abstract() end
function IFileSystem:IsDirectoryExist() Class3.Abstract() end
function IFileSystem:IsFileExists() Class3.Abstract() end

---@class IFileContext
local IFileContext = Class3.Interface('IFileContext')

function IFileContext:ChangeDirectory() Class3.Abstract() end
function IFileContext:ReadStringFile() Class3.Abstract() end
function IFileContext:GetCurrentDirectory() Class3.Abstract() end

return {
    IFileSystem = IFileSystem,
    IFileContext = IFileContext,
}