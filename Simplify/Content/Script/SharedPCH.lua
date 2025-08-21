---
---@brief SharedPreCompiled Header
---@author zys
---@data Sat Apr 05 2025 14:07:07 GMT+0800 (中国标准时间)
---@notice 此文件的修改必须征得本人同意(全局变量增加要慎重)!!!
---


log = require('Util.Log') ---@type log
debug_util = require('Util/debug_util')

_ = require("Util.Class.class1")
class = require("Util.Class.class2") ---@type class
_ = require("Util.Class.test1")
_ = require("Util.Class.test2")

duplex = require("Util/Duplex‌/duplex") ---@type duplex
_ = require("Util/Duplex‌/test")
msg_bus = require("Util.msg_bus") ---@type msgbus

table_util = require('Util/table_util')
world_util = require("Util/world_util")
gas_util = require('Util/gas_util')
actor_util = require('Util/actor_util')
decision_util = require('Util/DecisionUtil')
obj_util = require('Util/obj_util') ---@type obj_util
net_util = require("Util/net_util")
async_util = require("Util/async_util")
math_util = require('Util/math_util')
ui_util = require("Util/UI/ui_util") ---@type ui_util
dev_util = require('Util/dev_util')
draw_util = require('Util/draw_util')

require('Ikun.Module.MdMgr')
require('Content/Role/Role')

rolelib = require('Content/Role/RoleLib') ---@type rolelib

require('Ikun/Module/AI/BT/LBT')
require("Ikun/Module/AI/MLP")
require("Ikun/Module/AI/Goap")