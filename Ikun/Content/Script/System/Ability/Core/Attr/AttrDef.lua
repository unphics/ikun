
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-属性声明
--  File        : AttrDef.lua
--  Author      : zhengyanshuai
--  Date        : Tue Jan 20 2026 22:56:49 GMT+0800 (中国标准时间)
--  Description : 属性声明
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

---@class AttrDef
---@field protected RefIdToKey table<number, string>
local AttrDef = {}

AttrDef.RefIdToKey = {}

---@public
---@param InKey string
---@return number
AttrDef.ToId = function(InKey)
    local id = tonumber(InKey)
    if not id then
        id = AttrDef[InKey]
    end
    return id
end

---@public
---@param InId number
---@return string
AttrDef.ToKey = function(InId)
    if type(InId) == 'string' then
        return InId
    end
    return AttrDef.RefIdToKey[InId]
end

---@public [Init]
AttrDef.BuildIdToKey = function()
    for k, v in pairs(AttrDef) do
        if type(k) == "string" then
            AttrDef.RefIdToKey[v] = k
        end
    end
end

return AttrDef