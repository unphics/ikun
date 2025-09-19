
---
---@brief   技能组件
---@author  zys
---@data    Sun Aug 31 2025 21:49:36 GMT+0800 (中国标准时间)
---

---@class SkillConfig
---@field SkillName string
---@field SkillDesc string
---@field AbilityTemplate string
---@field SkillEffects number[]
---@field TargetActors number[]
---@field AbilityAnims string[]
---@field Params table

---@class SkillComp: SkillComp_C
---@field AllSkill table
local SkillComp = UnLua.Class()

-- function SkillComp:Initialize(Initializer)
-- end

-- function SkillComp:ReceiveBeginPlay()
-- end

-- function SkillComp:ReceiveEndPlay()
-- end

-- function SkillComp:ReceiveTick(DeltaSeconds)
-- end

---@public
function SkillComp:InitRoleSkill()
    self.AllSkill = {}
    local role = rolelib.role(self:GetOwner())
    if not role then
        return
    end
    local roleCfg = MdMgr.RoleMgr:GetRoleConfig(role:GetRoleCfgId()) ---@type RoleConfig
    local allSkillCfg = MdMgr.ConfigMgr:GetConfig('Skill')
    if not roleCfg.RoleSkills then
        return
    end
    local asc = self:GetOwner().ASC ---@as UIkunASC
    for _, skillId in ipairs(roleCfg.RoleSkills) do
        local skillCfg = allSkillCfg[skillId] ---@type SkillConfig
        local abilityClass = gas_util.find_ability_class(skillCfg.AbilityTemplate)
        local handle = nil
        if skillId == 530201 then
            local triggerTag = UE.UIkunFnLib.RequestGameplayTag('Skill.Type.Trigger.Normal')
            handle = asc:GiveAbilityWithDynTriggerTag(abilityClass, triggerTag, 0, 0)
        else
            handle = asc:K2_GiveAbility(abilityClass, 0, 0)
        end
        if handle and handle ~= -1 then
            table.insert(self.AllSkill, {Id = skillId, Handle = handle, Cfg = skillCfg})
        end
    end
end

---@public
---@param Tag FGameplayTag
function SkillComp:TryActiveSkillByTag(Tag)
    if not Tag then
        return
    end
    log.info('SkillComp:TryActiveSkillByTag', Tag.TagName)
    local asc = self:GetOwner().ASC
    for _, skillInfo in ipairs(self.AllSkill) do
        local ability = UE.UAbilitySystemBlueprintLibrary.GetGameplayAbilityFromSpecHandle(asc, skillInfo.Handle, false)
        if UE.UBlueprintGameplayTagLibrary.HasTag(ability.AbilityTags, Tag, true) then
            local payload = UE.FGameplayEventData() ---@type FGameplayEventData
            local obj = obj_util.new_uobj()
            obj.SkillConfig = skillInfo.Cfg
            payload.OptionalObject = obj
            UE.UAbilitySystemBlueprintLibrary.SendGameplayEventToActor(self:GetOwner(), Tag, payload)
            break
        end
    end
end

return SkillComp
