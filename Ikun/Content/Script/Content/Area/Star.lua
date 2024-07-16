--[[
    @brief 星球
]]

require("Content.District.DistrictMgr")

class.class "Star" {
    Name = nil,
    DistrictMgr = nil,
    ctor = function(self, Name)
        self.StarName = Name
        self.DistrictMgr = class.new "DistrictMgr" (self.StarName)
    end,
}