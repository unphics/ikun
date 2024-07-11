local MdBase = require("Ikun.Module.MdBase")
local ConMgr = require("Content.ConMgr")
local class = require("Util.Class.class1")

---@class MdMgr
class.class "MdMgr" : extends "MdBase" {
    MdName = "MdMgr",
    tbMd = {
        ConMgr = class.new"ConMgr"()
    },
    ctor = function(self)
        
    end,
    Init = function(self)
        self.super.Init(self)
        for _, Md in pairs(self.tbMd) do
            Md:Init()
        end
    end,
    Tick = function(self, DeltaTime)
        for _, Md in pairs(self.tbMd) do 
            Md:Tick(DeltaTime)
        end
    end
}