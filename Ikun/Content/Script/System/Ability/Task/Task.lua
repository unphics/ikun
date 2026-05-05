
local Class3 = require("Core/Class/Class3")
local log = require("Core/Log/log")
local Delegate = require("Core/Delegate")

---@class Task
---@field OnMontageEnd Delegate
local Task = Class3.Class("Task")

---@public
function Task.PlayMontageAndWait(Skill, Montage)
    local task = Task:New()
    task.Skill = Skill
    task.Montage = Montage
    local part = Skill:GetSkillOwnerPart() ---@as AbilityPartClass
    task.Avatar = part:GetOwnerRole().Avatar

    return task
end

function Task:Ctor()
    self.OnMontageEnd = Delegate:New()
end

function Task:Ready()
    local animInst = self.Avatar.Mesh:GetAnimInstance() ---@type UAnimInstance
    animInst.OnMontageEnded:Add(self.Avatar, function()
        self:_MontageEnd()
    end)
    local time = animInst:Montage_Play(self.Montage, 1, UE.EMontagePlayReturnType.Duration, 0, true)
end

function Task:_MontageEnd()
    local animInst = self.Avatar.Mesh:GetAnimInstance() ---@type UAnimInstance
    animInst.OnMontageEnded:Remove(self.Avatar, self._MontageEnd)
    log.mark("qqqqqq")
    self.OnMontageEnd:BroadcastCallback()
end

return Task