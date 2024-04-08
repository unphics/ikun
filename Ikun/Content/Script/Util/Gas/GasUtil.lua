gas_util = {}

local function find_active(ikun_chr, tag_container)
    local GA = nil
    local Abilitys = UE.TArray(UE.UIkunGABase)
    ikun_chr:GetAbilitySystemComponent():GetActivateAbilitiesWithTag(tag_container, Abilitys)
    for _, Ability in pairs(Abilitys) do
        -- 判断TagContainer中包含Tag
        if UE.UBlueprintGameplayTagLibrary.HasTag(Ability.AbilityTags, UE.UIkunFuncLib.RequestGameplayTag('Chr.Skill.Born'), true) then
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
    return gas_util.find_active_by_tag(ikun_chr, UE.UIkunFuncLib.RequestGameplayTag(name))
end

---@public ASC添加Tag
gas_util.asc_add_tag_by_container = function(ikun_chr, container)
    UE.UAbilitySystemBlueprintLibrary.AddLooseGameplayTags(ikun_chr, container, true)
end

---@public ASC添加Tag
gas_util.asc_add_tag_by_tag = function(ikun_chr, tag)
    local TagContainer = UE.FGameplayTagContainer()
    TagContainer.GameplayTags:Add(tag)
    UE.UAbilitySystemBlueprintLibrary.AddLooseGameplayTags(ikun_chr, TagContainer, true)
end

---@public ASC添加Tag
gas_util.asc_add_tag_by_name = function(ikun_chr, name)
    gas_util.asc_add_tag_by_tag(ikun_chr, UE.UIkunFuncLib.RequestGameplayTag(name))
end

---@public 判断ASC包含Tag
gas_util.asc_has_tag_by_tag = function(ikun_chr, tag)
    return ikun_chr:GetAbilitySystemComponent():HasGameplayTag(tag)
end

---@public 判断ASC包含Tag
gas_util.asc_has_tag_by_name = function(ikun_chr, name)
    return ikun_chr:GetAbilitySystemComponent():HasGameplayTag(UE.UIkunFuncLib.RequestGameplayTag(name))
end

---@public 从ASC中查找Abilities
---@return table<Ability,Handle>
gas_util.find_abilities_by_name = function(ikun_chr, name)
    local ASC = ikun_chr:GetAbilitySystemComponent()
    local AbilityHandles = UE.TArray(UE.FGameplayAbilitySpecHandle)
    ASC:GetAllAbilities(AbilityHandles)
    local ActivableAbilities = {}
    for i = 1, AbilityHandles:Length() do
        local Handle = AbilityHandles:Get(i)
        local Ability = UE.UAbilitySystemBlueprintLibrary.GetGameplayAbilityFromSpecHandle(ASC, Handle)
        if UE.UBlueprintGameplayTagLibrary.HasTag(Ability.AbilityTags, name, true) then
            table.insert(ActivableAbilities, {Handle = Handle, Ability = Ability})
        end
    end
    return ActivableAbilities
end

return gas_util