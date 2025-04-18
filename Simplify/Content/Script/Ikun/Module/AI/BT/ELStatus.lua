---@enum ELStatus
local ELStatus = {
    Failure = 1, -- 失败
    Success = 2, -- 成功
    Running = 3, -- 运行中
    Aborted = 4, -- 中断
    Invalid = 5, -- 无效
}

---@param Status ELStatus
ELStatus.PrintLStatus = function(Status)
    local Arr = {'Failure', 'Success', 'Running', 'Aborted', 'Invalid'}
    local Text = Arr[Status]
    if Text == 'Running' then
        Text = Text .. '    <---------'
    end
    return Text
end

return ELStatus