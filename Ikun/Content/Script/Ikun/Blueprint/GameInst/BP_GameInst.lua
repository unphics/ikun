--- 一些全局的工具在这里引用
local log = require('Util.Debug.Log')
local class = require('Util.Class.class')
local MdMgr = require('Ikun.Module.MdMgr')
local GasUtil = require('Util.Gas.GasUtil')
local ActorUtil = require('Util.Actor.ActorUtil')
local DecisionUtil = require('Util.AI.DecisionUtil')
local ObjUtil = require('Util.Obj.ObjUtil')

---@class BP_GameInst: BP_GameInst_C
local M = UnLua.Class()

function M:ReceiveInit()
    self.Overridden.ReceiveInit(self)
    -- 此处是客户端和服务器最早启动的地方, 因此可以在这里做一些初始化全局或者静态的东西
    log.warn('BP_GameInstanceBase:ReceiveInit')
end

return M