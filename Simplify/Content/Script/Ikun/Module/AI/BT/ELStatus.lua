---@enum ELStatus
local ELStatus = {
    Failure = 'Failure', -- 失败
    Success = 'Success', -- 成功
    Running = 'Running', -- 运行中
    Aborted = 'Aborted', -- 中断
    Invalid = 'Invalid', -- 无效
}

---@param Status ELStatus
ELStatus.PrintLStatus = function(Status)
    -- local Arr = {'Failure', 'Success', 'Running', 'Aborted', 'Invalid'}
    -- local Text = Arr[Status]
    local Text = Status
    if Text == 'Running' then
        Text = Text .. '    <---------'
    end
    return Text
end

return ELStatus