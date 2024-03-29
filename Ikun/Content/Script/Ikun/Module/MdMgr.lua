local MdBase = require("Ikun.Module.MdBase")
local ConMgr = require("Content.ConMgr")

---@class MdMgr
---@field tbMd table
local MdMgr = class.create(MdBase)

-- register
MdMgr.tbMd = {
    ConMgr = ConMgr:new()
}

function MdMgr:ctor()
    
end

function MdMgr:Init()
    for _,Md in pairs(self.tbMd) do
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
