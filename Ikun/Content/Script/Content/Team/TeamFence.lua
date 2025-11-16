
---
---@brief 团队栅栏
---@author zys
---@data Fri Apr 25 2025 20:57:18 GMT+0800 (中国标准时间)
---

---@class TeamFenceClass
---@field OwnerTeam TeamClass
---@field arrFnCallback function[]
local TeamFenceClass = class.class 'TeamFenceClass' {
--[[public]]
    ctor = function()end,
    RegisterTogether = function()end,
--[[private]]
    IsAllMemberRegister = function()end,
    TriggerCallback = function()end,
}
function TeamFenceClass:ctor(Team)
    self.OwnerTeam = Team
    self.arrFnCallback = {}
end
---@public
---@param fnCallback function
function TeamFenceClass:RegisterTogether(fnCallback)
    table.insert(self.arrFnCallback, fnCallback)

    if self:IsAllMemberRegister() then
        self:TriggerCallback()
    end
end
---@private
function TeamFenceClass:TriggerCallback()
    for _, fn in ipairs(self.arrFnCallback) do
        fn()
    end
    self.arrFnCallback = {}
    log.dev('TeamFenceClass:TriggerCallback() 一个同步栏栅')
end
---@private
function TeamFenceClass:IsAllMemberRegister()
    local AllMember = self.OwnerTeam.TeamMember:GetAllMember()
    local RoleCount = 0
    local CallbackCount = #self.arrFnCallback
    for i, ele in ipairs(AllMember) do
        local Role = ele ---@type RoleBaseClass
        if not Role:IsRoleDead() then
            RoleCount = RoleCount + 1
        end
    end
    if CallbackCount >= RoleCount then
        return true
    end
    return false
end

return TeamFenceClass