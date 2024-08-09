--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class GA_Katana_Skill_01
local GA_Katana_Skill_01 = UnLua.Class('Ikun.Blueprint.GAS.GA.BP_IkunGA')

---@private [Override]
function GA_Katana_Skill_01:OnActivateAbility()
    self.Overridden.OnActivateAbility(self)
    log.log('katana skill 01', 'begin')
    
    if not self.MontageToPlay then
        log.log('katana skill 01', 'failed to find montage')
        self:GAFail()
        return
    end
    
    self.OwnerChr = self:GetAvatarActorFromActorInfo()
    
    ---@type UATPlayMtgAndWaitEvent
    self.WaitMtg = UE.UATPlayMtgAndWaitEvent.PlayMtgAndWaitEvent(self, 'task name', self.MontageToPlay, UE.UGameplayTagContainer,  1.0 , '', false, 1.0)
    self.WaitMtg.OnBlendOut:Add(self, self.OnCompleted)
    self.WaitMtg.OnCompleted:Add(self, self.OnCompleted)
    self.WaitMtg.OnInterrupted:Add(self, self.OnCancelled)
    self.WaitMtg.OnCancelled:Add(self, self.OnCancelled)
    -- self.WaitMtg.EventReceived:Add(self, self.EventReceived)
    self.WaitMtg:ReadyForActivation()

    -- self.OwnerChr.Mesh:GetAnimInstance():Montage_Play(self.MontageToPlay)

    self.WaitInput = UE.UAbilityAsync_WaitGameplayEvent.WaitGameplayEventToActor(self.OwnerChr, UE.UIkunFuncLib.RequestGameplayTag("Input.MouseLeft.Down"), false, true)
    self.WaitInput.EventReceived:Add(self.OwnerChr, function(chr, payload)
        self:OnInputMouseLeftDown(payload)
    end)
    self.WaitInput:Activate()

    self.WaitSection = UE.UAbilityAsync_WaitGameplayEvent.WaitGameplayEventToActor(self.OwnerChr, UE.UIkunFuncLib.RequestGameplayTag("Chr.Skill.Section"), false, true)
    self.WaitSection.EventReceived:Add(self.OwnerChr, function(chr, payload)
        self:OnSkillSectionTrigger(payload)
    end)
    self.WaitSection:Activate()

    self.SectionState = 0
    self.SectionIndex = 1

    self.OnAbilityEnd:Add(self , function()
        if self.OwnerChr:HasAuthority() then
            log.error("katana skill 01", 'end')
            if self.WaitMtg:IsValid() then
                self.WaitMtg:EndTask()
            end
            if self.WaitMtg:IsValid() then
                self.WaitInput:EndAction()
            end
            if self.WaitMtg:IsValid() then
                self.WaitSection:EndAction()
            end
        end
    end)
end

-- ---@private [Override]
-- function GA_Katana_Skill_01:OnEndAbility(WasCancelled)
--     self.Overridden.OnEndAbility(self, WasCancelled)
--     log.error("katana skill 01", 'end', '-'..self:GetAvatarActorFromActorInfo().aaa..'-')
--     if self.OwnerChr:HasAuthority() then
--         self:GetAvatarActorFromActorInfo().aaa = false
--     end
-- end

function GA_Katana_Skill_01:OnCompleted(EventTag, EventData)
    log.error("katana OnCompleted")
    self:GASuccess()
end

function GA_Katana_Skill_01:OnCancelled(EventTag, EventData)
    log.error("katana OnCancelled")
    -- self:GAFail()
end

function GA_Katana_Skill_01:EventReceived(EventTag, EventData)
    log.error("katana EventReceived")
    -- self:GASuccess()
end

function GA_Katana_Skill_01:OnInputMouseLeftDown(payload)
    if self.OwnerChr:HasAuthority() then
        if self.SectionState == 1 then
            log.error("katana skill 01", 'Mouse Left Down', self.SectionIndex)
            self.SectionState = 2
        end
    end
end

--[[
    0 开始接收输入
    1 停止接收输入
    2 接收到输入
]]

function GA_Katana_Skill_01:OnSkillSectionTrigger(payload)
    if self.OwnerChr:HasAuthority() then
        log.error("katana skill 01", 'On Skill Section', self.SectionState, payload.OptionalObject.SectionIndex)
        if self.SectionState == 0 then -- 开始接收输入
            self.SectionState = 1
            return
        end
    end
    if self.SectionState == 1 then -- 收刀
        log.error("katana skill 01", '收刀', self.OwnerChr:HasAuthority(), self.SectionIndex)
        self.OwnerChr.Mesh:GetAnimInstance():Montage_JumpToSection("attack_0" .. self.SectionIndex .. "_end", self.MontageToPlay)
        return
    end
    if self.OwnerChr:HasAuthority() then
        self.SectionState = 0
        self.SectionIndex = payload.OptionalObject.SectionIndex
    end
end

return GA_Katana_Skill_01