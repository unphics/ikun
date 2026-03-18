
---
---@brief   ConfigSystemInterface
---@author  zys
---@todo    叫ConfigContext还是叫ConfigHandle呢？
---@data    Sat Jan 03 2026 00:06:07 GMT+0800 (中国标准时间)
---

local Class3 = require('Core/Class/Class3')

---@class IConfigSystem
local IConfigSystem = Class3.Interface('IConfigSystem')

function IConfigSystem:InitConfigSystem() Class3.Abstract() end
function IConfigSystem:CreateCSVParser() Class3.Abstract() end
function IConfigSystem:ReleaseParser() Class3.Abstract() end

---@class IConfigParser
local IConfigParser = Class3.Interface('IConfigParser')

function IConfigParser:Ctor() Class3.Abstract() end
function IConfigParser:GetResult() Class3.Abstract() end
function IConfigParser:ReleaseParser() Class3.Abstract() end


return {
    IConfigSystem = IConfigSystem,
    IConfigParser = IConfigParser,
}