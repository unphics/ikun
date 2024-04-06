local class = require('Util.Class.class')

decision_util = {}

---@class stick 竹签
local stick = class.create()

function stick:ctor(idx, obj, weight)
    self.idx = idx
    self.obj = obj
    self.weight = math.floor(math.abs(weight))
end

function stick:add_weight(weight)
    self.weight = self.weight + math.floor(math.abs(weight))
end

---@class lot_pot 签筒
local lot_pot = class.create()

function lot_pot:ctor()
    self._idx = 1
    self.pot = {}
end

---@public 入签
function lot_pot:add_stick(obj, weight)
    local stick = stick:new(self._idx, obj, weight and weight or 0)
    self._idx = self._idx + 1
    table.insert(self.pot, stick)
    return stick
end

---@public 抽签
function lot_pot:draw_lot()
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

decision_util.lot_pot = lot_pot

return decision_util