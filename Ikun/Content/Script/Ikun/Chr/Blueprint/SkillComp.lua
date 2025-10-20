
---
---@brief   技能组件
---@author  zys
---@data    Sun Aug 31 2025 21:49:36 GMT+0800 (中国标准时间)
---

local SLOT_NAME_HEAD = 'Skill.Type.Trigger.'

---@class SkillConfig
---@field SkillName string
---@field SkillDesc string
---@field AbilityTemplate string
---@field SkillEffects number[]
---@field TargetActors number[]
---@field AbilityAnims string[]
---@field Params table

---@class SkillComp: SkillComp_C
---@field _SkillSlot table
local SkillComp = UnLua.Class()

---@public 初始化角色的技能
function SkillComp:InitRoleSkill()
    local role = rolelib.role(self:GetOwner())

    local roleCfg = RoleMgr:GetRoleConfig(role:GetRoleCfgId()) ---@type RoleConfig
    if not roleCfg.RoleSkills then
        log.info('SkillComp:InitRoleSkill()', '无初始技能', role:RoleName())
        return
    end

    ---@todo zys 技能槽
    self._SkillSlot = {
        Equip = nil,
        UnEquip = nil,
        Dodge = nil,
        NormalOne = nil,
        NormalTow = nil,
        Hit = nil,
        Special = nil,
    }

    for slot, skillId in pairs(roleCfg.RoleSkills) do
        self:SetSlotSkill(slot, skillId)
    end
end

---@public 激活技能 [Server]
---@param SlotName string
function SkillComp:TryActiveSlotSkill(SlotName)
    if net_util.is_client(self:GetOwner()) then
        log.error('SkillComp:TryActiveSlotSkill()', '只能在服务端调用')
        return
    end
    log.info('SkillComp:TryActiveSlotSkill()', SlotName)
    local skillInfo = self._SkillSlot[SlotName]
    if not skillInfo then
        log.warn('SkillComp:TryActiveSlotSkill()', '空槽位')
        return
    end

    local Tag = UE.UIkunFnLib.RequestGameplayTag(SLOT_NAME_HEAD..SlotName)
    if not Tag or not Tag.TagName then
        log.error('SkillComp:TryActiveSlotSkill()', '无效的Tag')
        return
    end
    
    local payload = UE.FGameplayEventData() ---@type FGameplayEventData
    local obj = obj_util.new_uobj()
    obj.SkillConfig = skillInfo.Config
    payload.OptionalObject = obj
    UE.UAbilitySystemBlueprintLibrary.SendGameplayEventToActor(self:GetOwner(), Tag, payload)
end

---@public
function SkillComp:SetSlotSkill(SlotName, SkillId)
    if self._SkillSlot[SlotName] then
        log.error('SkillComp:SetSlotSkill() 该槽位已经存在技能')
        return
    end

    local allSkillCfg = ConfigMgr:GetConfig('Skill') ---@type table<number, SkillConfig>
    local config = allSkillCfg[SkillId] ---@type SkillConfig
    if not config then
        log.error('SkillComp:SetSlotSkill() 无效的技能Id')
        return
    end

    local slotTagName = SLOT_NAME_HEAD..SlotName
    local slotTag = UE.UIkunFnLib.RequestGameplayTag(slotTagName)
    if not slotTag or not slotTag.TagName then 
        log.error('SkillComp:SetSlotSkill() 非法的技能槽位')
        return
    end
    
    local abilityClass = gas_util.find_ability_class(config.AbilityTemplate)
    local asc = self:GetOwner().ASC ---@as UIkunASC
    local handle = asc:GiveAbilityWithDynTriggerTag(abilityClass, slotTag, 0, 0)

    if handle and handle ~= -1 then
        self._SkillSlot[SlotName] = {Id = SkillId, Handle = handle, Config = config, TagName = SlotName}
    end
end

---@public
function SkillComp:UnsetSlotSkill(SlotName)
    local slotTagName = SLOT_NAME_HEAD..SlotName
    local slotTag = UE.UIkunFnLib.RequestGameplayTag(slotTagName)
    if not slotTag or not slotTag.TagName then 
        log.error('SkillComp:UnsetSlotSkill() 非法的技能槽位')
        return
    end

    local skillInfo = self._SkillSlot[SlotName]
    local asc = self:GetOwner().ASC ---@as UIkunASC
    asc:ClearAbility(skillInfo.Handle)
    self._SkillSlot[SlotName] = nil
end

return SkillComp