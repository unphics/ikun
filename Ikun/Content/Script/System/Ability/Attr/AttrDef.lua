
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

local table_util = require("Core/Util/table_util")

---@class AttrDef
---@field protected RefIdToKey table<number, string>
---@field public Attr table<string, number>
local AttrDef = {}

AttrDef.Attr = {}
AttrDef.RefIdToKey = {}

---@public
---@param InKey string
---@return number
AttrDef.ToId = function(InKey)
    local id = tonumber(InKey)
    if not id then
        id = AttrDef.Attr[InKey]
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
    local len = table_util.map_len(AttrDef.Attr)
    AttrDef.RefIdToKey = table_util.make_arr(len, "Undefined")
    for k, v in pairs(AttrDef.Attr) do
        if type(k) == "string" and type(v) == "number" then
            AttrDef.RefIdToKey[v] = k
        end
    end
end

return AttrDef
