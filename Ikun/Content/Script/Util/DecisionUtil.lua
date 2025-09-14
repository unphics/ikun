

local decision_util = {}

---@class stick 竹签
class.class"stick"{
    idx = 0,
    obj = nil,
    weight = 0,
    ctor = function(self, idx, obj, weight)
        self.idx = idx
        self.obj = obj
        self.weight = math.floor(math.abs(weight))
    end,
    add_weight = function(self, weight)
        self.weight = self.weight + math.floor(math.abs(weight))
    end
}
---@class lot_pot 签筒
class.class"lot_pot"{
    _idx = 1,
    pot = {},
    ctor = function(self) end,
    ---@public 入签
    add_stick = function(self, obj, weight)
        local stick = class.new"stick"(self._idx, obj, weight and weight or 0)
        self._idx = self._idx + 1
        table.insert(self.pot, stick)
        return stick
    end,
    ---@public 抽签
    draw_lot = function(self)
        local max = 0
        for _, ele in pairs(self.pot) do
            max = max + ele.weight
        end
        local random = math.random(0, math.floor(max))
        local result = nil
        for _, ele in pairs(self.pot) do
            random = random - ele.weight
            if random <= 0 then
                result = ele
                break
            end
        end
        return result.obj
    end
}

decision_util.lot_pot = function()
    return class.new"lot_pot"()
end

return decision_util