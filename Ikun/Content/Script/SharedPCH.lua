---
---@brief Shared Precompiled Header
---

log = require('Util.Log')
_ = require("Util.Class.class1")
class = require("Util.Class.class2")
_ = require("Util.Class.test1")
_ = require("Util.Class.test2")

world_util = require("Util.WorldUtil")
gas_util = require('Util.GasUtil')
actor_util = require('Util.ActorUtil')
decision_util = require('Util.DecisionUtil')
obj_util = require('Util.ObjUtil')
net_util = require("Util.NetUitl")
async_util = require("Util.AsyncUtil")
ui_util = require("Util.UI.UI_Util")

require('Ikun.Module.MdMgr')
require('Content/Role/Role')

require('Ikun/Module/AI/BT/LBT')
require("Ikun/Module/AI/MLP")
require("Ikun/Module/AI/Goap")