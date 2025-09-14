
---
---@brief GameplayAbilitySystem的工具方法
---@author zys
---@data Sun May 04 2025 14:20:00 GMT+0800 (中国标准时间)
---

local gas_util = {}

local function find_active(ikun_chr, tag_container)
    local GA = nil
    local Abilitys = UE.TArray(UE.UIkunGABase)
    ikun_chr:GetAbilitySystemComponent():GetActivateAbilitiesWithTag(tag_container, Abilitys)
    for _, Ability in pairs(Abilitys) do
        -- 判断TagContainer中包含Tag
        if UE.UBlueprintGameplayTagLibrary.HasAnyTags(Ability.AbilityTags, tag_container, true) then
            GA = Ability
        end
    end
    return GA
end

---@public 查找激活的技能
gas_util.find_active_by_container = function(ikun_chr, container)
    return find_active(ikun_chr, container)
end
---@public 查找激活的技能
gas_util.find_active_by_tag = function(ikun_chr, tag)
    local TagContainer = UE.FGameplayTagContainer()
    TagContainer.GameplayTags:Add(tag)
    return find_active(ikun_chr, TagContainer)
end
---@public 查找激活的技能
gas_util.find_active_by_name = function(ikun_chr, name)
    return gas_util.find_active_by_tag(ikun_chr, UE.UIkunFnLib.RequestGameplayTag(name))
end

---@public
---@param tag string|FGameplayTag|FGameplayTagContainer
gas_util.add_loose_tag = function(ikun_chr, tag)
    if not obj_util.is_valid(ikun_chr) then
        return log.error('gas_util.add_loose_tag(): invalid ikun_chr', debug.traceback())
    end
    local container = nil
    if tag.GameplayTags then
        container = tag
    elseif tag.TagName then
        container = UE.FGameplayTagContainer()
        container.GameplayTags:Add(tag)
    else
        container = UE.FGameplayTagContainer()
        container.GameplayTags:Add(UE.UIkunFnLib.RequestGameplayTag(tag))
    end
    UE.UAbilitySystemBlueprintLibrary.AddLooseGameplayTags(ikun_chr, container, true)
end

---@public
---@param tag string|FGameplayTag|FGameplayTagContainer
gas_util.remove_loose_tag = function(ikun_chr, tag, bShouldRep)
    if not obj_util.is_valid(ikun_chr) then
        return log.error('gas_util.remove_loose_tag(): invalid ikun_chr', debug.traceback())
    end
    bShouldRep = bShouldRep or true
    local container = nil
    if tag.GameplayTags then
        container = tag
    elseif tag.TagName then
        container = UE.FGameplayTagContainer()
        container.GameplayTags:Add(tag)
    else
        container = UE.FGameplayTagContainer()
        container.GameplayTags:Add(UE.UIkunFnLib.RequestGameplayTag(tag))
    end
    UE.UAbilitySystemBlueprintLibrary.RemoveLooseGameplayTags(ikun_chr, container, true)
end

---@public
---@param tag string|FGameplayTag|FGameplayTagContainer
gas_util.has_loose_tag = function(ikun_chr, tag)
        if not obj_util.is_valid(ikun_chr) then
        return log.error('gas_util.remove_loose_tag(): invalid ikun_chr', debug.traceback())
    end
    local container = nil
    if tag.GameplayTags then
        container = tag
    elseif tag.TagName then
        container = UE.FGameplayTagContainer()
        container.GameplayTags:Add(tag)
    else
        container = UE.FGameplayTagContainer()
        container.GameplayTags:Add(UE.UIkunFnLib.RequestGameplayTag(tag))
    end
    return UE.UIkunFnLib.HasLooseGameplayTags(ikun_chr, container)
end

---@public 从ASC中查找Abilities
---@todo 看看这个是Ability还是AbilityHandle
gas_util.find_abilities_by_name = function(ikun_chr, name)
    local ASC = ikun_chr:GetAbilitySystemComponent()
    local AbilityHandles = UE.TArray(UE.FGameplayAbilitySpecHandle)
    ASC:GetAllAbilities(AbilityHandles)
    local ActivableAbilities = {}
    for i = 1, AbilityHandles:Length() do
        local Handle = AbilityHandles:Get(i)
        local Ability = UE.UAbilitySystemBlueprintLibrary.GetGameplayAbilityFromSpecHandle(ASC, Handle, false)
        if UE.UBlueprintGameplayTagLibrary.HasTag(Ability.AbilityTags, UE.UIkunFnLib.RequestGameplayTag(name), true) then
            table.insert(ActivableAbilities, {Handle = Handle, Ability = Ability})
        end
    end
    return ActivableAbilities
end

---@public 获取ASC被Give的所有AbilitySpec
---@return FGameplayAbilitySpec[]
gas_util.get_all_ability_spec = function(ikun_chr)
    return ikun_chr.ASC.ActivatableAbilities.Items:ToTable()
end

---@public
---@return UGameplayAbility[]
gas_util.get_all_abilities = function(ikun_chr)
    local abilities = {}
    for _, spec in ipairs(gas_util.get_all_ability_spec(ikun_chr)) do
        table.insert(abilities, spec.Ability)
    end
    return abilities
end

---@public 获取所有主动技能
---@version 1.0.0
---@notice 主动技能的TagName后续待定Chr.Skill.Type.Active
---@return UGameplayAbility[]
gas_util.get_all_active_abilities = function(ikun_chr)
    local abilities = {}
    local handles = {}
    for _, spec in ipairs(gas_util.get_all_ability_spec(ikun_chr)) do
        if UE.UBlueprintGameplayTagLibrary.HasTag(spec.Ability.AbilityTags, UE.UIkunFnLib.RequestGameplayTag('Skill.Tag.Active'), false) then
            table.insert(abilities, spec.Ability)
            table.insert(handles, spec.Handle)
        end
    end
    return abilities, handles
end

---@public 获取血量百分比
---@version 1.0.0
---@return number
gas_util.get_health_per = function(Chr)
    local health = Chr.AttrSet:GetAttrValueByName("Health")
    local maxHealth = Chr.AttrSet:GetAttrValueByName("MaxHealth")
    return health / maxHealth
end

return gas_util