
--[[
-- -----------------------------------------------------------------------------
--  Brief       : TagContainer
--  File        : TagContainer.lua
--  Author      : zhengyanshuai
--  Date        : Sat Jan 03 2026 20:28:06 GMT+0800 (中国标准时间)
--  Description : 能力系统-标签容器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local ffi = require('ffi')
local fficlass = require('Core/FFI/fficlass')
local TagManager = require('System/Ability/Tag/TagManager')

ffi.cdef [[
    typedef struct {
        uint8_t counts[1024];
    } TagContainer;
]]

---@class TagContainer
---@field counts integer[]
local TagContainer = fficlass.define('TagContainer')

---@public
---@param InTagId integer
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

---@public
---@param InTagId integer
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

---@public
---@param InTagId integer
---@return boolean
function TagContainer:HasTag(InTagId)
    return self.counts[InTagId] > 0
end

---@public
---@param InTags integer[]
---@return boolean
function TagContainer:HasAnyTags(InTags)
    for i = 1, #InTags do
        local tagId = InTags[i]
        if self.counts[tagId] > 0 then
            return true
        end
    end
    return false
end

TagContainer = TagContainer:RegisterClass()

return TagContainer