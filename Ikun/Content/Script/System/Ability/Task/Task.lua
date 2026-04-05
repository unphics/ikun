
local Class3 = require("Core/Class/Class3")
local log = require("Core/Log/log")

---@class Task
local Task = Class3.Class("Task")

function Task:ctor()
    
end

---@public
function Task.PlayMontageAndWait(Skill, Montage)
    local task = Task:New()
    task.Skill = Skill
    task.Montage = Montage
    local part = Skill:GetSkillOwner() ---@as AbilityPartClass
    task.Avatar = part:GetOwnerRole().Avatar

    return task
end

function Task:Ready()
    local animInst = self.Avatar.Mesh:GetAnimInstance() ---@type UAnimInstance
    animInst.OnMontageEnded:Add(self.Avatar, function()
        self:OnMontageEnd()
    end)
    local time = animInst:Montage_Play(self.Montage, 1, UE.EMontagePlayReturnType.Duration, 0, true)
end

function Task:OnMontageEnd()
    local animInst = self.Avatar.Mesh:GetAnimInstance() ---@type UAnimInstance
    animInst.OnMontageEnded:Remove(self.Avatar, self.OnMontageEnd)
    log.mark("qqqqqq")
end

return Task