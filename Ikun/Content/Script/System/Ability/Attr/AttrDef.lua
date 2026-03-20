
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

local table_util = require("Core/Utils/table_util")

---@class AttrDef
---@field protected RefIdToKey table<integer, string>
---@field public Attr table<string, integer>
---@field public AttrCount integer
local AttrDef = {}

AttrDef.AttrCount = 0
AttrDef.Attr = {}
AttrDef.RefIdToKey = {}

---@public
---@param InKey integer|string
---@return integer
AttrDef.ToId = function(InKey)
    local id = tonumber(InKey)
    if not id then
        id = AttrDef.Attr[InKey]
    end
    return id
end

---@public
---@param InId integer|string
---@return string
AttrDef.ToKey = function(InId)
    if type(InId) == 'string' then
        return InId
    end
    return AttrDef.RefIdToKey[InId]
end

---@public [Init]
AttrDef.BuildIdToKey = function()
    AttrDef.AttrCount = table_util.map_len(AttrDef.Attr)
    AttrDef.RefIdToKey = table_util.make_arr(AttrDef.AttrCount, "Undefined")
    for k, v in pairs(AttrDef.Attr) do
        if type(k) == "string" and type(v) == "number" then
            AttrDef.RefIdToKey[v] = k
        end
    end
end

return AttrDef
