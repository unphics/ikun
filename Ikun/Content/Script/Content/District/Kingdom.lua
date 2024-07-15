
class.class"Kingdom"{
    tbZone = {},
    ctor = function(self, Name)
    end,
    Init = function(self)
        local zone = class.new "Zone" ("default")
        table.insert(self.tbZone, zone)
    end,
    AddSettlement = function(self, Settlement)
        self.tbZone[1]:AddSettlement(Settlement)
    end
}