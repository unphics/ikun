
class.class"Kingdom"{
    tbZone = {},
    ctor = function(self, Name)
        local zone = class.new "Zone" ("default")
        table.insert(self.tbZone, zone)
    end,
    Init = function(self)
    end,
    AddSettlement = function(self, Settlement)
        self.tbZone[1]:AddSettlement(Settlement)
    end,
    FindSettlementLua = function(self, Id)
        for i, zone in ipairs(self.tbZone) do
            for j, settlement in ipairs(zone.tbSettlement) do
                if j == Id then
                    return settlement
                end
            end
        end
    end
}