---
---@brief 对话的数据结构
---@author zys
---@data Sun Feb 02 2025 19:45:31 GMT+0800 (中国标准时间)
---

local Type = {
    Select = 1,
    Content = 2,
}

local Data = {}

---@class ConversationData
Data[1] = {
    Type = Type.Content,
    Content = '开始测试!',
    SelectList = {},
    NextId = 7,
    Fn = nil,
}

Data[2] = {
    Type = Type.Content,
    Content = '选哪个呢1选哪个呢1',
    NextId = 5,
}

Data[3] = {
    Type = Type.Content,
    Content = '选哪个呢2选哪个呢2',
    NextId = 6,
}

Data[4] = {
    Type = Type.Content,
    Content = '选哪个呢3选哪个呢3',
    NextId = 7,
}

Data[5] = {
    Type = Type.Content,
    Content = '我是普通对话1我是普通对话1我是普通对话1我是普通对话1',
    NextId = 6,
}

Data[6] = {
    Type = Type.Content,
    Content = '我是普通对话2我是普通对话2我是普通对话2我是普通对话2',
    NextId = 8,
}

Data[7] = {
    Type = Type.Select,
    Content = '',
    SelectList = {2, 3, 4},
    NextId = 2,
}

Data[8] = {
    Type = Type.Content,
    Content = '我是普通对话3我是普通对话3我是普通对话3我是普通对话3',
    NextId = 7,
}



return {
    Data = Data,
    Type = Type
}