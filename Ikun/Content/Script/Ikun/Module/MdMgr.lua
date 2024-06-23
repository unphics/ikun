local MdBase = require("Ikun.Module.MdBase")
local ConMgr = require("Content.ConMgr")

---@class MdMgr
---@field tbMd table
local MdMgr = class.create(MdBase)

function MdMgr:ctor()
    self.super.ctor(self)
    self.name = 'MdMgr'
    self.tbMd = {
        ConMgr = ConMgr:new()
    }
    log.warn('zys 1')
end

function MdMgr:Init()
    self.q = self.q and self.q + 1 or 0
    self.super.Init(self)
    log.warn("zys test", type(self.tbMd), debug.traceback())
    a = a + 1
    log.error('zys a', a)
    for _, Md in pairs(self.tbMd) do
        Md:Init()
    end
end

---@param DeltaTime number
function MdMgr:Tick(DeltaTime)
    for _, Md in pairs(self.tbMd) do 
        Md:Tick(DeltaTime)
    end
end

return MdMgr
