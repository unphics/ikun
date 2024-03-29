local MdBase = require("Ikun.Module.MdBase")

---@class ConMgr
local ConMgr = class.create(MdBase)

function ConMgr:ctor()
    log.log('con mgr ctor')
end

function ConMgr:Init()
    log.log('con mgr init')
end

---@param DeltaTime number
function ConMgr:Tick(DeltaTime)
    -- log.log('con mgr tick')
end

return ConMgr