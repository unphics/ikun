
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 通用预包含
--  File        : SharedPCH.lua
--  Author      : zhengyanshuai
--  Date        : Sat Apr 05 2025 14:07:07 GMT+0800 (中国标准时间)
--  Description : SharedPreCompiledHeader
--  Warn        : 此文件的修改必须征得本人同意(全局变量增加要慎重)!!!
--  Todo        : 考虑重新设计封装
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

do
    class = require('Core/Class/class')
    math_util = require('Core/Utils/math_util') ---@type math_util
    table_util = require('Core/Utils/table_util') ---@type table_util
    str_util = require('Core/Utils/str_util') ---@type str_util
end



require('Module/Modules')
modules = class.new'Modules'() ---@type Modules

do
    world_util = require("Utils/world_util")
    gas_util = require('Utils/gas_util') ---@type gas_util
    actor_util = require('Utils/actor_util')
    obj_util = require('Utils/obj_util') ---@type obj_util
    net_util = require("Utils/net_util")
    async_util = require("Utils/async_util")
    ui_util = require("Utils/UI/ui_util") ---@type ui_util
    draw_util = require('Utils/draw_util')
end

do
    require('Ikun/Module/Config/ConfigMgr')
    require('Content/Time/TimeMgr')
    require('Content/Item/ItemMgr')
    require('System/Role/RoleMgr')
    require('Content/Quest/QuestMgr')
    require("Content/Area/Cosmos")

    ConfigMgr = class.new 'ConfigMgr'() ---@as ConfigMgr
    TimeMgr = class.new 'TimeMgr'() ---@as TimeMgr
    ItemMgr = class.new 'ItemMgr'() ---@as ItemMgr
    RoleMgr = class.new 'RoleMgrClass'() ---@as RoleMgrClass
    TeamMgr = class.new 'TeamMgr'() ---@as TeamMgr
    QuestMgr = class.new 'QuestMgr'() ---@as QuestMgr
    Cosmos = class.new 'CosmosClass'() ---@as CosmosClass
end

do
    rolelib = require('System/Role/RoleLib') ---@type rolelib
end

do
    goap = require("System/Goap/Goap") ---@type goap
end

do
    
    local MoveStuckMonitor = require('Ikun/Module/Nav/MoveStuckMonitor')
    local NavMoveData = require('Ikun/Module/Nav/NavMoveData')
    local NavMoveBehav = require('Ikun/Module/Nav/NavMoveBehav')
end
