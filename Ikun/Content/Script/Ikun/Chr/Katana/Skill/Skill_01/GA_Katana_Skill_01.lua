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
    log.log('katana skill 01', '技能开始释放')
    
    if not self.MontageToPlay then
        log.log('katana skill 01', 'failed to find montage')
        self:GAFail()
        return
    end
    
    self.OwnerChr = self:GetAvatarActorFromActorInfo()
    gas_util.asc_add_tag_by_name(self.OwnerChr, "Chr.Skill.01")
    
    ---@type UATPlayMtgAndWaitEvent
    self.WaitMtg = UE.UATPlayMtgAndWaitEvent.PlayMtgAndWaitEvent(self, 'task name', self.MontageToPlay, UE.UGameplayTagContainer,  1.0 , '', false, 1.0)
    self.WaitMtg.OnBlendOut:Add(self, self.OnCompleted)
    self.WaitMtg.OnCompleted:Add(self, self.OnCompleted)
    self.WaitMtg.OnInterrupted:Add(self, self.OnCancelled)
    self.WaitMtg.OnCancelled:Add(self, self.OnCancelled)
    self.WaitMtg.EventReceived:Add(self, self.EventReceived)
    self.WaitMtg:ReadyForActivation()

    self.SectionState = 0
    self.SectionIndex = 1

    self.OnAbilityEnd:Add(self , function()
        if self.OwnerChr:HasAuthority() then
            log.log("katana skill 01", '技能结束')
            gas_util.asc_remove_tag_by_name(self.OwnerChr, 'Chr.Skill.01')
            if self.WaitMtg:IsValid() then
                self.WaitMtg:EndTask()
            end
        end
    end)
end

-- ---@private [Override]
-- function GA_Katana_Skill_01:OnEndAbility(WasCancelled)
--     self.Overridden.OnEndAbility(self, WasCancelled)
--     log.log("katana skill 01", 'end', '-'..self:GetAvatarActorFromActorInfo().aaa..'-')
--     if self.OwnerChr:HasAuthority() then
--         self:GetAvatarActorFromActorInfo().aaa = false
--     end
-- end

function GA_Katana_Skill_01:OnCompleted(EventTag, EventData)
    log.log("katana skill 01 OnCompleted 播放完成", self.OwnerChr:HasAuthority())
    self:GASuccess()
end

function GA_Katana_Skill_01:OnCancelled(EventTag, EventData)
    log.log("katana skill 01 OnCancelled")
    self:GAFail()
end

function GA_Katana_Skill_01:EventReceived(EventTag, EventData)
    log.log("katana skill 01 EventReceived",
        "svr:" .. tostring(self.OwnerChr:HasAuthority()),
        'tag:'..tostring(EventData.EventTag.TagName), 
        'index:' .. tostring(EventData.OptionalObject and EventData.OptionalObject.SectionIndex or nil)
    )
    local is_svr = self.OwnerChr:HasAuthority()
    if EventData.EventTag.TagName == 'Input.MouseLeft.Down' and is_svr and self.SectionState == 1 then
        log.log("katana skill 01", '玩家点击左键', self.SectionIndex)
        self.SectionState = 2
    elseif EventData.EventTag.TagName == 'Chr.Skill.Section' then
        if is_svr and EventData.OptionalObject.SectionState == 0 then
            self.SectionState = 1
            log.log('katana skill 01', '阶段' .. self.SectionIndex, '开始接收输入')
        elseif EventData.OptionalObject.SectionState == 1 then
            if self.SectionState == 1 then
                log.log("katana skill 01", '阶段' .. self.SectionIndex, "没有玩家输入", '收刀', self.OwnerChr:HasAuthority())
                self.OwnerChr.Mesh:GetAnimInstance():Montage_JumpToSection("attack_0" .. self.SectionIndex .. "_end", self.MontageToPlay)
            elseif is_svr then
                self.SectionState = 0
                self.SectionIndex = EventData.OptionalObject.SectionIndex
            end
        end
    end
end

--[[
    0 开始接收输入
    1 停止接收输入
    2 接收到输入
]]

return GA_Katana_Skill_01