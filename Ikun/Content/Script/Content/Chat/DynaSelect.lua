
---
---@brief   动态对话
---@author  zys
---@data    Fri Aug 29 2025 22:54:01 GMT+0800 (中国标准时间)
---


local QuestTool = require('Content/Quest/QuestTool')
local ChatCondLib = require('Content/Chat/ChatCondLib')

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
            local config = RoleMgr:GetRoleConfig(id)
            if config and config.RoleChat then
                local outSelects = {}
                for _, chatId in ipairs(config.RoleChat) do
                    local chatData = NpcChat:GetChatData(chatId)
                    if chatData then
                        if chatData.Cond then
                            if ChatCondLib.TryCheckCond(NpcChat, chatData.Cond) then
                                table.insert(outSelects, chatId)    
                            end
                        else
                            table.insert(outSelects, chatId)
                        end
                    end
                end
                return outSelects
            end
        end        
    end
    return {}
end

return DynaSelect