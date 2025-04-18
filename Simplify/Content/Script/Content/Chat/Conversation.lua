---
---@brief 对话
---@author zys
---@data Sun Feb 02 2025 19:45:31 GMT+0800 (中国标准时间)
---@todo 这玩意现在没用
---@notice 这玩意现在没用
---

local Config = require('Content/Chat/Config/ConversationConfig')

---@class Conversation
---@field ConversationId number
local Conversation = class.class "Conversation" {
---[[public]]
    ctor = function()end,
--[[private]]
    ConversationId = nil,
}
function Conversation:ctor(ConversationId)
    self.ConversationId = ConversationId
    
end