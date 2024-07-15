--[[
    @brief 星球
]]

class.class "Star" {
    Name = nil,
    DistrictMgr = nil,
    ctor = function(self, Name)
        self.Name = Name
        self.DistrictMgr = class.new "DistrictMgr" (self.Name)
    end,
}