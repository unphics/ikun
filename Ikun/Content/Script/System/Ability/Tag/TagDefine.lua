
---
---@brief   TagDefine
---@author  zys
---@data    Sat Jan 03 2026 20:28:06 GMT+0800 (中国标准时间)
---

local TagManager = require('System/Ability/Core/Tag/TagManager').Get()

local Tags = {
    'skill.type.active',
}

local TagDefine = {}

for _, tag in ipairs(Tags) do
    TagDefine[tag] = TagManager:Register(tag)
end

return TagDefine