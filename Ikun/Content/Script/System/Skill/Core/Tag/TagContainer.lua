
---
---@brief   TagContainer
---@author  zys
---@data    Sat Jan 03 2026 20:28:06 GMT+0800 (中国标准时间)
---

local ffi = require('ffi')
local fficlass = require('Core/FFI/fficlass')
local TagManager = require('System/Skill/Core/Tag/TagManager')

ffi.cdef [[
    typedef struct {
        uint8_t counts[1024];
    } TagContainer;
]]

---@class TagContainer
---@field counts number[]
local TagContainer = fficlass.define('TagContainer')

---@public
function TagContainer:AddTag(InTagId)
    -- 增加自己计数
    self.counts[InTagId] = self.counts[InTagId] + 1

    -- 增加父级计数
    local pCache = TagManager.Get().ParentCache[InTagId]
    for i = 0, pCache.count - 1 do
        local pid = pCache.ids[i]
        self.counts[pid] = self.counts[pid] + 1
    end
end

function TagContainer:RemoveTag(InTagId)
    if self.counts[InTagId] > 0 then
        self.counts[InTagId] = self.counts[InTagId] - 1

        local pCache = TagManager.Get().ParentCache[InTagId]
        for i = 0, pCache.count - 1 do
            local pid = pCache.ids[i]
            self.counts[pid] = self.counts[pid] - 1
        end
    end
end

function TagContainer:HasTag(InTagId)
    return self.counts[InTagId] > 0
end

TagContainer = TagContainer:Register()

return TagContainer