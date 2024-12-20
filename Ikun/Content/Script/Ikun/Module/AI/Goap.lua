---
---@brief 目标导向的行为规划
---

local WorldState = class.class 'WorldState' {
    ctor = function()end,
    GetState = function()end,
    SetState = function()end,
    Copy = function()end,
    Print = function()end,
    Data = nil,
}
function WorldState:ctor(Data)
    self.Data = Data or {}
end
function WorldState:GetState(Key)
    return self.Data[Key]
end
function WorldState:SetState(Key, Value)
    self.Data[Key] = Value
end
function WorldState:Copy()
    local State = class.new 'WorldState' ()
    for k, v in pairs(self.Data) do
        State:SetState(k, v)
    end
    return State
end
function WorldState:Print()
    local Text = 'WorldState: {'
    for k, v in pairs(self.Data) do
        Text = Text .. tostring(k) .. ' = ' .. tostring(v) .. ', '
    end
    Text = Text .. '}'
    return Text
end