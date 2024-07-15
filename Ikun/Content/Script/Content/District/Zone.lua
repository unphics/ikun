--[[
    @brief 大区
]]
class.class"Zone"{
    tbSettlement = {},
    ctor = function(self, Name)
    end,
    Init = function (self)
        
    end,
    AddSettlement = function (self, Settlement)
        table.insert(self.tbSettlement, Settlement)
    end,
}