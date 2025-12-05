
---
---@brief   SharedPreCompiledHeader, 通用预包含
---@author  zys
---@data    Sat Apr 05 2025 14:07:07 GMT+0800 (中国标准时间)
---@notice  此文件的修改必须征得本人同意(全局变量增加要慎重)!!!
---

do
    log = require('Core/Log/log') ---@type log
    class = require('Core/Class/class')
    math_util = require('Core/Util/math_util') ---@type math_util
    table_util = require('Core/Util/table_util') ---@type table_util
    str_util = require('Core/Util/str_util') ---@type str_util
end

debug_util = require('Util/debug_util')

require('Module/Modules')
modules = class.new'Modules'() ---@type Modules

do
    world_util = require("Util/world_util")
    gas_util = require('Util/gas_util') ---@type gas_util
    actor_util = require('Util/actor_util')
    obj_util = require('Util/obj_util') ---@type obj_util
    net_util = require("Util/net_util")
    async_util = require("Util/async_util")
    ui_util = require("Util/UI/ui_util") ---@type ui_util
    draw_util = require('Util/draw_util')
end

do
    require('Ikun/Module/Config/ConfigMgr')
    require('Content/Time/TimeMgr')
    require('Content/Item/ItemMgr')
    require('Module/Role/RoleMgr')
    require('Content/Quest/QuestMgr')
    require("Content/Area/Cosmos")

    gameinit = require('Core/Init/gameinit') ---@type gameinit

    ConfigMgr = class.new 'ConfigMgr'() ---@as ConfigMgr
    TimeMgr = class.new 'TimeMgr'() ---@as TimeMgr
    ItemMgr = class.new 'ItemMgr'() ---@as ItemMgr
    RoleMgr = class.new 'RoleMgrClass'() ---@as RoleMgrClass
    TeamMgr = class.new 'TeamMgr'() ---@as TeamMgr
    QuestMgr = class.new 'QuestMgr'() ---@as QuestMgr
    Cosmos = class.new 'CosmosClass'() ---@as CosmosClass
end

do
    rolelib = require('Module/Role/RoleLib') ---@type rolelib
end

do
    goap = require("System/Goap/Goap") ---@type goap
end

do
    
    local MoveStuckMonitor = require('Ikun/Module/Nav/MoveStuckMonitor')
    local NavMoveData = require('Ikun/Module/Nav/NavMoveData')
    local NavMoveBehav = require('Ikun/Module/Nav/NavMoveBehav')
end

gameinit.triggerinit(gameinit.groups.env_init)