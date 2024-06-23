--[[
    @brief 游戏内容
]]
local MdBase = require("Ikun.Module.MdBase")

---@class ConMgr
local ConMgr = class.create(MdBase)

function ConMgr:ctor()
    self.super.ctor(self)
    log.log('con mgr ctor')
    self.name = 'ConMgr'
    self.tbCon = {
        WillMgr = require("Content.Will.WillMgr"):new()
    }
end

function ConMgr:Init()
    self.super.Init(self)
    log.log('con mgr init')
    for k, v in pairs(self.tbCon) do
        v:Init()
    end
end

---@param DeltaTime number
function ConMgr:Tick(DeltaTime)
    -- log.log('con mgr tick')
end

return ConMgr