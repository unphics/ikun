
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-增益-增益配置
--  File        : BuffConfig.lua
--  Author      : zhengyanshuai
--  Date        : Tue Feb 10 2026 14:19:55 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local ConfigSystem = require("System/Config/ConfigSystem")
local FileSystem = require("System/File/FileSystem")
local log = require('Core/Log/log')

---@class BuffConfig
---@field public BuffKey string
---@field public BuffName string
---@field public BuffTemplate string
---@field public BuffDuration number
---@field public Period number
---@field public GrantedTags number[]        -- TagId[]
---@field public BlockTags number[]          -- TagId[]
---@field public CancelTags number[]         -- TagId[]

---@class BuffConfigClass
---@field private __BuffConfigs table<string, BuffConfig>
local BuffConfigClass = Class3.Class("BuffConfigClass")

local BUFF_CONFIG_PATH = "Ability/Buff/Buff.csv"
local config = nil

---@public
---@return BuffConfigClass
function BuffConfigClass.Get()
    if not config then
        config = BuffConfigClass:New()
    end
    return config
end

function BuffConfigClass:Ctor()
    self:__LoadBuffConfigs()
end

---@private
function BuffConfigClass:__LoadBuffConfigs()
    self.__BuffConfigs = {}


    local file = FileSystem.Get():MustReadSConfigFile(BUFF_CONFIG_PATH)
    log.assert_fmt(file, "BuffConfigClass:__LoadBuffConfigs(): Failed to read [%s]", BUFF_CONFIG_PATH)

    local parser = ConfigSystem.Get():CreateCSVParser(file)
    local config = parser:ToRows():ExtractHeaders():ToGrid():ToMap():GetResult()
    parser:ReleaseParser()
    self.__BuffConfigs = config
end

---@public
---@return BuffConfig
function BuffConfigClass:LookupBuffConfig(InBuffKey)
    return self.__BuffConfigs[InBuffKey]
end

return BuffConfigClass