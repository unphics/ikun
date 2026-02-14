
---
---@brief   TagManager
---@author  zys
---@data    Sat Jan 03 2026 20:28:06 GMT+0800 (中国标准时间)
---

local ffi = require('ffi')
local Class3 = require('Core/Class/Class3')

local MAX_TAG_COUTN = 1024
local MAX_PARENT_DEPATH = 8 -- 假设Tag层级深度最多8层(A.B.C.D...)

ffi.cdef [[
    typedef struct {
        uint16_t count;
        uint16_t ids[8];
    } ParentList;
]]

---@class TagManager
local TagManager = Class3.Class('TagManager')

local manager = nil

---@public
function TagManager:Ctor()
    self.TagToId = {}
    self.NextId = 0
    self.ParentCache = ffi.new('ParentList[?]', MAX_TAG_COUTN)
end

---@public
---@return TagManager
function TagManager.Get()
    if not manager then
        manager = TagManager:New()
    end
    return manager
end

---@public
function TagManager:Register(InTag)
    if self.TagToId[InTag] then
        return self.TagToId[InTag]
    end

    local id = self.NextId
    assert(id < MAX_TAG_COUTN, 'Tag Id overflow!')
    self.NextId = id + 1
    self.TagToId[InTag] = id

    -- 解析父级
    local parts = {}
    for part in InTag:gmatch("([^%.]+)") do
        table.insert(parts, part)
    end

    local cache = self.ParentCache[id]
    cache.count = 0

    -- 逆向查找所有父级
    for i = 1, #parts - 1 do
        local parentStr = table.concat(parts, '.', 1, i)
        local pid = self:Register(parentStr) -- 递归确保父级先注册

        if cache.count < MAX_PARENT_DEPATH then
            cache.ids[cache.count] = pid
            cache.count = cache.count + 1
        else
            error('Tag depth exceeds MAX_PARENT_DEPATH: ' .. InTag)
        end
    end

    return id
end

return TagManager