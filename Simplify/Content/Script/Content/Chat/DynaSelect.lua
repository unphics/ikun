
local QuestTool = require('Content/Quest/QuestTool')
local RoleConfig = require('Content/Role/Config/RoleConfig')

---@class DynaSelect
local DynaSelect = {}

---@param NpcChat NpcChatClass
---@param SelectData ChatConfig[]
DynaSelect.CalcSelectInfo = function(NpcChat, SelectData)
    if SelectData.Content == 'NpcChat' then
        local target = NpcChat.ChatTarget
        local targetRole = rolelib.role(target)
        if targetRole then
            local id = targetRole:GetRoleCfgId()
            local config = RoleConfig[id]
            if config and config.Chat then
                return config.Chat
            end
        end        
    end
    return {}
end

return DynaSelect