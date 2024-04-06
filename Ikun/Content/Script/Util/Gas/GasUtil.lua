gas_util = {}

local function find_active(ikun_chr, tag_container)
    local GA = nil
    local Abilitys = UE.TArray(UE.UIkunGABase)
    ikun_chr:GetAbilitySystemComponent():GetActivateAbilitiesWithTag(tag_container, Abilitys)
    for _, Ability in pairs(Abilitys) do
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

return gas_util